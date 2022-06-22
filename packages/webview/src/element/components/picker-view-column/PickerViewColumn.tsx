import { ref, computed, getCurrentInstance, onMounted, nextTick, defineComponent } from "vue"
import useTouch from "../../use/useTouch"
import { useParent, ParentProvide } from "../../use/useRelation"
import { PICKER_VIEW_KEY, PickerViewProvide } from "../picker-view/define"
import { Easing } from "@tweenjs/tween.js"
import { vibrateShort, NZJSBridge } from "../../../bridge"
import { clamp } from "@nzoth/shared"
import useJSAnimation from "../../use/useJSAnimation"

export default defineComponent({
  name: "nz-picker-view-column",
  setup(_, { expose }) {
    const instance = getCurrentInstance()!

    const groupRef = ref<HTMLElement>()

    const indicatorRef = ref<HTMLElement>()

    const contentRef = ref<HTMLElement>()

    const translateY = ref<number>(0)

    let parent: ParentProvide<PickerViewProvide> | undefined

    let startPositionY = 0
    let offsetY = 0

    let currentIndex = 0

    onMounted(() => {
      addTouchEvent()

      setTimeout(() => {
        parent = useParent(instance, PICKER_VIEW_KEY)
        if (!parent) {
          console.warn("picker-view-column 必须添加在 picker-view 内")
        }
      })
    })

    const getIndex = (y: number) => {
      return clamp(Math.round(-y / itemHeight), 0, totalCount - 1)
    }

    const momentumTimeThreshold = 300
    const momentumYThreshold = 15
    let momentumOffsetY = 0
    let startTime = 0
    let prevIndex = 0

    const addTouchEvent = () => {
      const { onTouchStart, onTouchMove, onTouchEnd } = useTouch(groupRef.value!)
      onTouchStart(() => {
        startPositionY = offsetY
        startTime = Date.now()
        momentumOffsetY = offsetY

        stopAnimation()

        parent && parent.onPickStart()
      })

      onTouchMove((ev, touch) => {
        ev.preventDefault()

        stopAnimation()

        let y = touch.deltaY.value + startPositionY
        if (y > 0) {
          y = y * 0.5
        }

        const index = getIndex(y)
        index !== prevIndex && playSound()

        translateY.value = y
        offsetY = y
        prevIndex = index
        currentIndex = index

        const now = Date.now()
        if (now - startTime > momentumTimeThreshold) {
          momentumOffsetY = y
          startTime = now
        }
      })

      onTouchEnd(() => {
        let distance = offsetY - momentumOffsetY
        const duration = Date.now() - startTime
        if (duration < momentumTimeThreshold && Math.abs(distance) > momentumYThreshold) {
          const speed = Math.abs(distance / duration)
          distance = offsetY + (speed / 0.003) * (distance < 0 ? -1 : 1)
          const index = getIndex(distance)
          animationTranslate(-index * itemHeight, 1000, true)
        } else if (offsetY > 0) {
          animationTranslate(0, 200, true)
        } else if (Math.abs(offsetY) > maxY) {
          animationTranslate(-maxY, 200, true)
        } else {
          const index = getIndex(offsetY)
          animationTranslate(-index * itemHeight, 200, true)
        }

        parent && parent.onPickEnd()
      })
    }

    const { startAnimation, stopAnimation } = useJSAnimation<{ y: number }>()

    const animationTranslate = (y: number, duration: number, animation: boolean) => {
      if (animation) {
        startAnimation({
          begin: { y: offsetY },
          end: { y },
          duration,
          easing: Easing.Cubic.Out,
          onUpdate: ({ y }) => {
            translateY.value = y
            offsetY = y
            const index = getIndex(offsetY)
            index !== prevIndex && playSound()
            prevIndex = index
            currentIndex = index
          },
          onComplete: () => {
            prevIndex = getIndex(offsetY)
            currentIndex = prevIndex
            parent && parent.onChange()
          }
        })
      } else {
        translateY.value = y
        offsetY = y
        prevIndex = getIndex(offsetY)
        currentIndex = prevIndex
      }
    }

    const playSound = () => {
      vibrateShort({ type: "light" })
      NZJSBridge.invoke("playSystemSound", { id: 1157 })
    }

    const indicatorTop = ref(0)
    let totalCount = 0
    let itemHeight = 0
    let maxY = 0

    const setHeight = (height: number) => {
      nextTick(() => {
        itemHeight = indicatorRef.value!.offsetHeight
        totalCount = contentRef.value!.children.length
        for (let i = 0; i < totalCount; i++) {
          const child = contentRef.value!.children.item(i) as HTMLElement
          child.style.height = itemHeight + "px"
          child.style.overflow = "hidden"
        }
        indicatorTop.value = (height - itemHeight) * 0.5
        indicatorRef.value!.style.top = indicatorTop.value + "px"
        maxY = itemHeight * (totalCount - 1)
      })
    }

    const indicatorStyle = ref<string>()

    const indicatorClass = ref<string>()

    const maskStyle = ref<string>()

    const maskClass = ref<string>()

    const combineMaskStyle = computed(() => {
      const top = `background-size: 100% ${indicatorTop.value}px;`
      if (maskStyle.value) {
        return !maskStyle.value.endsWith(";") ? `${maskStyle.value};${top}` : maskStyle.value + top
      }
      return top
    })

    const setValue = (value: number) => {
      nextTick(() => {
        const index = value ? clamp(value, 0, totalCount - 1) : 0
        prevIndex = index
        currentIndex = index
        animationTranslate(-index * itemHeight, 0, false)
      })
    }

    expose({
      setIndicatorStyle: (value: string) => {
        indicatorStyle.value = value
      },
      setIndicatorClass: (value: string) => {
        indicatorClass.value = value
      },
      setMaskStyle: (value: string) => {
        maskStyle.value = value
      },
      setMaskClass: (value: string) => {
        maskClass.value = value
      },
      setHeight,
      setValue,
      getCurrent: () => currentIndex
    })

    return () => {
      const _maskClass = "nz-picker-view-column__mask " + maskClass.value
      const _indicatorClass = "nz-picker-view-column__indicator " + indicatorClass.value
      return (
        <nz-picker-view-column>
          <div ref={groupRef} class="nz-picker-view-column__group">
            <div class={_maskClass} style={combineMaskStyle.value}></div>
            <div ref={indicatorRef} class={_indicatorClass} style={indicatorStyle.value}></div>
            <div
              ref={contentRef}
              class="nz-picker-view-column__content"
              style={{
                transform: `translate3d(0, ${translateY.value}px, 0)`,
                padding: `${indicatorTop.value}px 0px`
              }}
            ></div>
          </div>
        </nz-picker-view-column>
      )
    }
  }
})
