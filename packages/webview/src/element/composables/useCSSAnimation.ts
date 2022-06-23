import { Ref, watch, nextTick } from "vue"
import { unitToPx } from "../utils/format"

type AnimationTimingFunction =
  | "linear"
  | "ease"
  | "ease-in"
  | "ease-in-out"
  | "ease-out"
  | "step-start"
  | "step-end"

interface AnimationOption {
  transformOrigin: string
  transition: {
    duration: number
    timingFunction: AnimationTimingFunction
    delay: number
  }
}

interface AnimationStepAction {
  type: string
  args: any[]
}

export interface AnimationAction {
  animations: AnimationStepAction[]
  option: AnimationOption
}

interface Props {
  animation: AnimationAction[]
}

export function useCSSAnimation(viewRef: Ref<HTMLElement | undefined>, props: Props) {
  let animateIdx = 0

  watch(
    () => [...props.animation],
    animation => {
      animateIdx = 0
      runAnimate(animation[animateIdx])
    }
  )

  const runAnimate = (anim: AnimationAction) => {
    if (!viewRef.value) {
      nextTick(() => {
        runAnimate(anim)
      })
      return
    }
    const view = viewRef.value
    const transform: string[] = []
    anim.animations.forEach(action => {
      const type = action.type
      switch (type) {
        case "style":
          const key = action.args[0]
          let value = action.args[1]
          if (!["background-color", "opacity"].includes(key)) {
            value = `${unitToPx(value)}px`
          }
          view.style[key] = value
          break
        case "rotate":
          transform.push(`${type}(${action.args[0]}deg)`)
          break
        case "rotateX":
          transform.push(`${type}(${action.args[0]}deg)`)
          break
        case "rotateY":
          transform.push(`${type}(${action.args[0]}deg)`)
          break
        case "rotateZ":
          transform.push(`${type}(${action.args[0]}deg)`)
          break
        case "rotate3d":
          transform.push(
            `${type}(${action.args[0]},${action.args[1]},${action.args[2]},${action.args[3]}deg)`
          )
          break
        case "scale":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "scaleX":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "scaleY":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "scaleZ":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "scale3d":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "translate":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "translateX":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "translateY":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "translateZ":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "translate3d":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "skew":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "skewX":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "skewY":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "matrix":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
        case "matrix3d":
          transform.push(`${type}(${action.args.join(", ")})`)
          break
      }
    })
    view.style.transform = transform.join(" ")
    view.style.transition = `${anim.option.transition.duration}ms ${anim.option.transition.timingFunction} ${anim.option.transition.delay}ms`
    view.style.transformOrigin = anim.option.transformOrigin
    view.addEventListener("webkitTransitionEnd", onTranslationEnd)
  }

  const onTranslationEnd = () => {
    viewRef.value!.removeEventListener("webkitTransitionEnd", onTranslationEnd)
    if (animateIdx < props.animation.length) {
      animateIdx += 1
      runAnimate(props.animation[animateIdx])
    }
  }

  return {}
}
