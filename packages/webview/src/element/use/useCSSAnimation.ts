import { ref, Ref, watch, nextTick } from "vue"

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

export default function useCSSAnimation(
  viewRef: Ref<HTMLElement | undefined>,
  props: Props
) {
  watch(
    () => [...props.animation],
    animation => {
      animateIdx = 0
      runAnimate(animation[animateIdx])
    }
  )

  let animateIdx = 0

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
          view.style[action.args[0]] = action.args[1]
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
          transform.push(`${type}(${action.args[0]},${action.args[1]})`)
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
          transform.push(
            `${type}(${action.args[0]},${action.args[1]},${action.args[2]},${action.args[3]})`
          )
          break
        case "translate":
          transform.push(`${type}(${action.args[0]},${action.args[1]})`)
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
          transform.push(
            `${type}(${action.args[0]},${action.args[1]},${action.args[2]})`
          )
          break
        case "skew":
          transform.push(`${type}(${action.args[0]},${action.args[1]})`)
          break
        case "skewX":
          transform.push(`${type}(${action.args[0]})`)
          break
        case "skewY":
          transform.push(`${type}(${action.args[0]})`)
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
