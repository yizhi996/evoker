import { Tween, update } from "@tweenjs/tween.js"

interface AnimationOptions<T> {
  begin: T
  end: T
  duration: number
  easing: (amount: number) => number
  onUpdate: (value: T) => void
  onComplete?: () => void
}

export default function useAnimation<T>() {
  let currentAnimation = 0
  let currentTween: Tween<T> | undefined

  const animate = () => {
    currentAnimation = requestAnimationFrame(animate)
    update()
  }

  const startAnimation = (options: AnimationOptions<T>) => {
    currentAnimation = requestAnimationFrame(animate)
    currentTween && currentTween.stop()

    currentTween = new Tween(options.begin)
      .to(options.end, options.duration)
      .easing(options.easing)
      .onUpdate(cb => {
        options.onUpdate(cb)
      })
      .onComplete(() => {
        cancelAnimationFrame(currentAnimation)
        options.onComplete && options.onComplete()
      })
      .start()
  }

  const stopAnimation = () => {
    cancelAnimationFrame(currentAnimation)
    currentTween && currentTween.stop()
  }

  return {
    startAnimation,
    stopAnimation
  }
}
