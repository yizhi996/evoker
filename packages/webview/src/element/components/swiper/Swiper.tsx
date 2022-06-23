import {
  onMounted,
  ref,
  watch,
  computed,
  getCurrentInstance,
  nextTick,
  PropType,
  defineComponent
} from "vue"
import { useChildren } from "../../composables/useRelation"
import { SWIPE_KEY } from "./constant"
import { useTouch } from "../../composables/useTouch"
import { Easing } from "@tweenjs/tween.js"
import { useJSAnimation } from "../../composables/useJSAnimation"
import { useResize } from "../../composables/useResize"
import { classNames } from "../../utils"

const props = {
  indicatorDots: { type: Boolean, default: false },
  indicatorColor: { type: String, default: "rgba(0, 0, 0, .3)" },
  indicatorActiveColor: { type: String, default: "#000" },
  autoplay: { type: Boolean, default: false },
  current: { type: Number, default: 0 },
  interval: { type: Number, default: 5000 },
  duration: { type: Number, default: 500 },
  circular: { type: Boolean, default: false },
  vertical: { type: Boolean, default: false },
  previousMargin: { type: String, default: "0px" },
  nextMargin: { type: String, default: "0px" },
  displayMultipleItems: { type: Number, default: 1 },
  easingFunction: {
    type: String as PropType<
      "default" | "linear" | "easeInCubic" | "easeOutCubic" | "easeInOutCubic"
    >,
    default: "default"
  }
}

export default defineComponent({
  name: "nz-swiper",
  props,
  emits: ["change", "transition", "animationfinish"],
  setup(props, { emit }) {
    const instance = getCurrentInstance()!

    const container = ref<HTMLElement>()

    const { children, linkChildren } = useChildren(SWIPE_KEY)

    linkChildren({})

    const itemCount = computed(() => {
      return children.length
    })

    const currentIndex = ref(0)
    const nextIndex = ref(0)

    const offset = ref(0)

    watch(
      () => [...children],
      () => {
        nextTick(() => {
          setChildStyle()
          scrollTo(props.current, Easing.Linear.None, 0, Sources.OTHER)
        })
      }
    )

    watch(
      () => props.circular,
      () => {
        setChildStyle()
      }
    )

    const transform = computed(() => {
      const boxSize = getBoxSize()
      const pos = -(offset.value / boxSize) * 100
      return props.vertical
        ? `translate(0px, ${pos}%) translateZ(0px)`
        : `translate(${pos}%, 0px) translateZ(0px)`
    })

    const slideMargin = computed(() => {
      let top = "0px"
      let left = "0px"
      let bottom = "0px"
      let right = "0px"
      if (props.vertical) {
        top = props.previousMargin
        bottom = props.nextMargin
      } else {
        left = props.previousMargin
        right = props.nextMargin
      }
      return {
        top,
        left,
        bottom,
        right
      }
    })

    watch(
      () => props.autoplay,
      () => {
        autoScroll()
      }
    )

    watch(
      () => props.current,
      () => {
        scrollTo(props.current, Easing.Linear.None, 0, Sources.OTHER)
      }
    )

    onMounted(() => {
      nextTick(() => {
        addTouchEvent()
        autoScroll()
      })
    })

    let autoScrollTimer: ReturnType<typeof setTimeout>

    const autoScroll = () => {
      clearTimeout(autoScrollTimer)
      if (props.autoplay) {
        autoScrollTimer = setTimeout(() => {
          let easing: (amount: number) => number
          switch (props.easingFunction) {
            case "easeInCubic":
              easing = Easing.Cubic.In
              break
            case "easeInOutCubic":
              easing = Easing.Cubic.InOut
              break
            case "easeOutCubic":
              easing = Easing.Cubic.Out
              break
            case "linear":
              easing = Easing.Linear.None
              break
            case "default":
            default:
              easing = Easing.Quadratic.InOut
              break
          }
          nextIndex.value += 1
          if (nextIndex.value > itemCount.value - 1) {
            nextIndex.value = 0
          }
          scrollTo(nextIndex.value, easing, props.duration, Sources.AUTOPLAY)
        }, props.interval)
      }
    }

    let rect: DOMRect | undefined

    const getBoxSize = () => {
      if (rect) {
        return (props.vertical ? rect.height : rect.width) / props.displayMultipleItems
      }
      return 0
    }

    let touching = false
    let touchStartTimestamp = 0

    let direction = 0

    const addTouchEvent = () => {
      if (container.value) {
        const { onResize } = useResize(container.value)
        onResize(_rect => {
          rect = _rect
        })

        const { onTouchStart, onTouchMove, onTouchEnd } = useTouch(container.value)
        onTouchStart(ev => {
          touchStartTimestamp = ev.timeStamp
          touching = true
          clearTimeout(autoScrollTimer)
        })

        onTouchMove((ev, touch) => {
          touching = true
          ev.preventDefault()

          stopAnimation()

          const boxSize = getBoxSize()

          let pos = currentIndex.value * boxSize
          if (props.vertical) {
            pos = pos - touch.deltaY.value
            if (!props.circular && pos < 0) {
              pos *= 0.5
            }
          } else {
            pos = pos - touch.deltaX.value
            if (!props.circular && pos < 0) {
              pos *= 0.5
            }
          }

          if (offset.value > pos) {
            direction = -1
          } else if (offset.value < pos) {
            direction = 1
          } else {
            direction = 0
          }

          offset.value = pos

          setChildStyleFromTouch(direction)
        })

        onTouchEnd((ev, touch) => {
          const duration = ev.timeStamp - touchStartTimestamp

          let current = currentIndex.value
          let next = current

          if (duration < 200) {
            if (direction < 0) {
              next -= 1
              if (next < 0) {
                if (props.circular) {
                  next = itemCount.value - 1
                } else {
                  next = 0
                }
              }
            } else if (direction > 0) {
              next += 1
              if (next > itemCount.value - 1) {
                if (props.circular) {
                  next = 0
                } else {
                  next = itemCount.value - 1
                }
              }
            }
            nextIndex.value = next
          } else {
            const boxSize = getBoxSize()
            next = Math.round(offset.value / boxSize)
            if (next < 0) {
              if (props.circular) {
                next = itemCount.value - Math.abs(next % itemCount.value)
              } else {
                next = 0
              }
            } else if (next > itemCount.value - 1) {
              if (props.circular) {
                next = Math.abs(next % itemCount.value)
              } else {
                next = itemCount.value - 1
              }
            }
            nextIndex.value = next
          }
          touching = false
          scrollTo(next, Easing.Linear.None, 250, Sources.TOUCH)
          autoScroll()
        })
      }
    }

    const { startAnimation, stopAnimation } = useJSAnimation<{ position: number }>()

    const enum Sources {
      AUTOPLAY = "autoplay",
      TOUCH = "touch",
      OTHER = ""
    }

    const scrollTo = (
      next: number,
      easing: (amount: number) => number,
      duration: number,
      source: Sources
    ) => {
      if (touching) {
        return
      }
      if (itemCount.value === 0) {
        return
      }

      const boxSize = getBoxSize()

      let begin = offset.value
      let end = next * boxSize

      if (props.circular) {
        if (source === Sources.AUTOPLAY) {
          if (currentIndex.value === itemCount.value - 1 && next === 0) {
            begin = -boxSize
          }
        } else if (currentIndex.value === 0 && next === itemCount.value - 1) {
          begin = itemCount.value * boxSize + offset.value
        } else if (currentIndex.value === itemCount.value - 1 && next === 0) {
          begin = -(itemCount.value * boxSize - offset.value)
        }
      }

      startAnimation({
        begin: { position: begin },
        end: { position: end },
        duration,
        easing,
        onUpdate: ({ position }) => {
          offset.value = position
          setChildStyle()
        },
        onComplete: () => {
          if (source !== Sources.OTHER) {
            instance.props.current = next
          }
          if (currentIndex.value !== next) {
            emit("change", { current: next, source })
          }
          currentIndex.value = next
          autoScroll()
        }
      })
    }

    const setChildStyle = () => {
      const min = 0
      const max = children.length - 1
      const boxSize = getBoxSize()
      let current = Math.round(offset.value / boxSize)

      if (current < min) {
        current = min
      } else if (current > max) {
        current = max
      }

      let width = "100%"
      let height = "100%"

      if (props.vertical) {
        height = 100 / props.displayMultipleItems + "%"
      } else {
        width = 100 / props.displayMultipleItems + "%"
      }

      children.forEach((child, i) => {
        const calcPos = () => {
          if (props.circular) {
            if (current === min) {
              if (i === max) {
                return "-100%"
              }
            } else if (current === max) {
              if (i === min) {
                return 100 * children.length + "%"
              }
            }
          }
          return 100 * i + "%"
        }

        let x = "0px"
        let y = "0px"
        if (props.vertical) {
          y = calcPos()
        } else {
          x = calcPos()
        }

        child.exposed!.setStyle(width, height, `translate(${x}, ${y}) translateZ(0px)`)
      })
    }

    const setChildStyleFromTouch = (direction: number) => {
      const boxSize = getBoxSize()
      let current = Math.round(offset.value / boxSize)

      if (!props.circular) {
        if (current < 0) {
          current = 0
        } else if (current > children.length - 1) {
          current = children.length - 1
        }
      }

      const setTransform = (index: number) => {
        let childIndex = Math.abs(index % children.length)
        if (index < 0) {
          childIndex = children.length - childIndex
          if (childIndex === children.length) {
            childIndex = 0
          }
        }
        const child = children[childIndex]
        if (child) {
          let x = "0px"
          let y = "0px"
          if (props.vertical) {
            y = 100 * index + "%"
          } else {
            x = 100 * index + "%"
          }
          child.exposed!.setTransform(`translate(${x}, ${y}) translateZ(0px)`)
        }
      }

      setTransform(current)

      if (props.circular) {
        if (direction < 0) {
          setTransform(Math.floor(offset.value / boxSize))
        } else {
          setTransform(Math.ceil(offset.value / boxSize))
        }
      }
    }

    return () => (
      <nz-swiper ref={container}>
        <div class="nz-swiper__wrapper">
          <div class="nz-swiper__slide" style={slideMargin.value}>
            <div
              class="nz-swiper__slide__frame"
              style={{ width: "100%", height: "100%", transform: transform.value }}
            ></div>
            {props.indicatorDots ? (
              <div
                class={classNames("nz-swiper__indicators", {
                  "nz-swiper__indicators--vertical": props.vertical
                })}
              >
                {[...Array(itemCount.value).keys()].map(i => {
                  return (
                    <i
                      class={classNames("nz-swiper__indicators__item", {
                        "nz-swiper__indicators__item--vertical": props.vertical
                      })}
                      style={{
                        "background-color":
                          i - 1 === currentIndex.value
                            ? props.indicatorActiveColor
                            : props.indicatorColor
                      }}
                    ></i>
                  )
                })}
              </div>
            ) : null}
          </div>
        </div>
      </nz-swiper>
    )
  }
})
