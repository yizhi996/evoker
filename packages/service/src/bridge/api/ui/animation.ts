type AnimationTimingFunction =
  | "linear"
  | "ease"
  | "ease-in"
  | "ease-in-out"
  | "ease-out"
  | "step-start"
  | "step-end"

interface CreateAnimationOptions {
  duration?: number
  timingFunction?: AnimationTimingFunction
  delay?: number
  transformOrigin?: string
}

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

class Animation {
  option: AnimationOption

  actions: AnimationAction[]

  currentStepAnimates: AnimationStepAction[]

  currentTransform: Record<string, AnimationStepAction>

  constructor(options: CreateAnimationOptions) {
    this.option = {
      transformOrigin: options.transformOrigin || "50% 50% 0",
      transition: {
        duration: options.duration ?? 400,
        timingFunction: options.timingFunction || "linear",
        delay: options.delay ?? 0
      }
    }
    this.actions = []
    this.currentStepAnimates = []
    this.currentTransform = {}
  }

  backgroundColor(value: string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["background-color", value]
    })
    return this
  }

  top(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["top", value]
    })
    return this
  }

  bottom(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["bottom", value]
    })
    return this
  }

  left(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["left", value]
    })
    return this
  }

  right(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["right", value]
    })
    return this
  }

  width(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["width", value]
    })
    return this
  }

  height(value: number | string) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["height", value]
    })
    return this
  }

  opacity(value: number) {
    this.currentStepAnimates.push({
      type: "style",
      args: ["opacity", value]
    })
    return this
  }

  rotate(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "rotate",
      args: [angle]
    })
    return this
  }

  rotateX(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "rotateX",
      args: [angle]
    })
    return this
  }

  rotateY(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "rotateY",
      args: [angle]
    })
    return this
  }

  rotateZ(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "rotateZ",
      args: [angle]
    })
    return this
  }

  rotate3d(x: number = 0, y: number = 0, z: number = 0, angle: number = 0) {
    this.currentStepAnimates.push({
      type: "rotate3d",
      args: [x, y, z, angle]
    })
    return this
  }

  scale(sx: number, sy?: number) {
    this.currentStepAnimates.push({
      type: "scale",
      args: [sx, sy ?? sx]
    })
    return this
  }

  scaleX(scale: number) {
    this.currentStepAnimates.push({
      type: "scaleX",
      args: [scale]
    })
    return this
  }

  scaleY(scale: number) {
    this.currentStepAnimates.push({
      type: "scaleY",
      args: [scale]
    })
    return this
  }

  scaleZ(scale: number) {
    this.currentStepAnimates.push({
      type: "scaleZ",
      args: [scale]
    })
    return this
  }

  scale3d(sx: number = 1, sy: number = 1, sz: number = 1) {
    this.currentStepAnimates.push({
      type: "scale3d",
      args: [sx, sy, sz]
    })
    return this
  }

  translate(tx: number = 0, ty: number = 0) {
    this.currentStepAnimates.push({
      type: "translate",
      args: [tx, ty]
    })
    return this
  }

  translateX(translation: number = 0) {
    this.currentStepAnimates.push({
      type: "translateX",
      args: [translation]
    })
    return this
  }

  translateY(translation: number = 0) {
    this.currentStepAnimates.push({
      type: "translateY",
      args: [translation]
    })
    return this
  }

  translateZ(translation: number = 0) {
    this.currentStepAnimates.push({
      type: "translateZ",
      args: [translation]
    })
    return this
  }

  translate3d(tx: number = 0, ty: number = 0, tz: number = 0) {
    this.currentStepAnimates.push({
      type: "translate3d",
      args: [tx, ty, tz]
    })
    return this
  }

  skew(ax: number = 0, ay: number = 0) {
    this.currentStepAnimates.push({
      type: "skew",
      args: [ax, ay]
    })
    return this
  }

  skewX(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "skewX",
      args: [angle]
    })
    return this
  }

  skewY(angle: number = 0) {
    this.currentStepAnimates.push({
      type: "skewY",
      args: [angle]
    })
    return this
  }

  matrix() {
    this.currentStepAnimates.push({
      type: "matrix",
      args: [1, 0, 0, 1, 1, 1]
    })
    return this
  }

  matrix3d() {
    this.currentStepAnimates.push({
      type: "matrix3d",
      args: [1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1]
    })
    return this
  }

  setp(options: CreateAnimationOptions = {}) {
    const option = {
      transformOrigin: options.transformOrigin || this.option.transformOrigin,
      transition: {
        duration: options.duration ?? this.option.transition.duration,
        timingFunction:
          options.timingFunction || this.option.transition.timingFunction,
        delay: options.delay ?? this.option.transition.delay
      }
    }

    const stepAnimates = this.currentStepAnimates || []
    const stepTransform: Record<string, AnimationStepAction> = {}
    stepAnimates.forEach(anim => {
      const key = anim.type === "style" ? anim.type + anim.args[0] : anim.type
      stepTransform[key] = anim
    })

    const transform = Object.assign({}, this.currentTransform, stepTransform)

    const animations: AnimationStepAction[] = []
    for (const action of Object.values(transform)) {
      animations.push(action)
    }

    animations.forEach(anim => {
      const key = anim.type === "style" ? anim.type + anim.args[0] : anim.type
      this.currentTransform[key] = anim
    })

    this.currentStepAnimates = []
    this.actions.push({ animations, option })
    return this
  }

  export() {
    const res = this.actions
    this.actions = []
    return res
  }
}

export function createAnimation(options: CreateAnimationOptions = {}) {
  return new Animation(options)
}
