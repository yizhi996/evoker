import { Ref } from "vue"
import { Canvas2DCommands } from "@evoker/shared"

const defineCommands = {
  [Canvas2DCommands.ARC]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.arc.apply(ctx, args)
  },
  [Canvas2DCommands.ARC_TO]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.arcTo.apply(ctx, args)
  },
  [Canvas2DCommands.BEGIN_PATH]: (ctx: CanvasRenderingContext2D) => {
    ctx.beginPath()
  },
  [Canvas2DCommands.BEZIER_CURVE_TO]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.bezierCurveTo.apply(ctx, args)
  },
  [Canvas2DCommands.CLEAR_RECT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.clearRect.apply(ctx, args)
  },
  [Canvas2DCommands.CLIP]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.clip.apply(ctx, args)
  },
  [Canvas2DCommands.CLOSE_PATH]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.closePath.apply(ctx, args)
  },
  [Canvas2DCommands.ELLIPSE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.ellipse.apply(ctx, args)
  },
  [Canvas2DCommands.FILL]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.fill.apply(ctx, args)
  },
  [Canvas2DCommands.FILL_RECT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.fillRect.apply(ctx, args)
  },
  [Canvas2DCommands.FILL_TEXT]: (ctx: CanvasRenderingContext2D, args: any) => {
    args[3] == null && (args[3] = undefined)
    ctx.fillText.apply(ctx, args)
  },
  [Canvas2DCommands.LINE_TO]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.lineTo.apply(ctx, args)
  },
  [Canvas2DCommands.MOVE_TO]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.moveTo.apply(ctx, args)
  },
  [Canvas2DCommands.QUADRATIC_CURVE_TO]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.quadraticCurveTo.apply(ctx, args)
  },
  [Canvas2DCommands.RECT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.rect.apply(ctx, args)
  },
  [Canvas2DCommands.RESET_TRANSFORM]: (ctx: CanvasRenderingContext2D) => {
    ctx.resetTransform()
  },
  [Canvas2DCommands.RESTORE]: (ctx: CanvasRenderingContext2D) => {
    ctx.restore()
  },
  [Canvas2DCommands.ROTATE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.rotate.apply(ctx, args)
  },
  [Canvas2DCommands.SAVE]: (ctx: CanvasRenderingContext2D) => {
    ctx.save()
  },
  [Canvas2DCommands.SCALE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.scale.apply(ctx, args)
  },
  [Canvas2DCommands.SET_LINE_DASH]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.setLineDash.apply(ctx, args)
  },
  [Canvas2DCommands.SET_TRANSFORM]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.setTransform.apply(ctx, args)
  },
  [Canvas2DCommands.STROKE]: (ctx: CanvasRenderingContext2D, args: any) => {
    args[0] ? ctx.stroke.apply(ctx, args) : ctx.stroke()
  },
  [Canvas2DCommands.STROKE_RECT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.strokeRect.apply(ctx, args)
  },
  [Canvas2DCommands.STROKE_TEXT]: (ctx: CanvasRenderingContext2D, args: any) => {
    args[3] == null && (args[3] = undefined)
    ctx.strokeText.apply(ctx, args)
  },
  [Canvas2DCommands.TRANSFORM]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.transform.apply(ctx, args)
  },
  [Canvas2DCommands.TRANSLATE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.translate.apply(ctx, args)
  },
  [Canvas2DCommands.SET_DIRECTION]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.direction = args[0]
  },
  [Canvas2DCommands.SET_FILL_STYLE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.fillStyle = args[0]
  },
  [Canvas2DCommands.SET_FILL_STYLE_BY_PATTERN]: (ctx: CanvasRenderingContext2D, args: any) => {
    const pattern = ctx.createPattern.apply(ctx, args)
    pattern && (ctx.fillStyle = pattern)
  },
  [Canvas2DCommands.SET_FILL_STYLE_BY_LINEAR_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 4
    const gradient = ctx.createLinearGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.fillStyle = gradient
  },
  [Canvas2DCommands.SET_FILL_STYLE_BY_RADIAL_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 6
    const gradient = ctx.createRadialGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.fillStyle = gradient
  },
  [Canvas2DCommands.SET_FILL_STYLE_BY_CONIC_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 3
    const gradient = ctx.createConicGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.fillStyle = gradient
  },
  [Canvas2DCommands.SET_FONT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.font = args[0]
  },
  [Canvas2DCommands.SET_GLOBAL_ALPHA]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.globalAlpha = args[0]
  },
  [Canvas2DCommands.SET_GLOBAL_COMPOSITE_OPERATION]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.globalCompositeOperation = args[0]
  },
  [Canvas2DCommands.SET_IMAGE_SMOOTHING_ENABLED]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.imageSmoothingEnabled = args[0]
  },
  [Canvas2DCommands.SET_IMAGE_SMOOTHING_QUALITY]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.imageSmoothingQuality = args[0]
  },
  [Canvas2DCommands.SET_LINE_CAP]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.lineCap = args[0]
  },
  [Canvas2DCommands.SET_LINE_DASH_OFFSET]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.lineDashOffset = args[0]
  },
  [Canvas2DCommands.SET_LINE_JOIN]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.lineJoin = args[0]
  },
  [Canvas2DCommands.SET_LINE_WIDTH]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.lineWidth = args[0]
  },
  [Canvas2DCommands.SET_MITER_LIMIT]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.miterLimit = args[0]
  },
  [Canvas2DCommands.SET_SHADOW_BLUR]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.shadowBlur = args[0]
  },
  [Canvas2DCommands.SET_SHADOW_COLOR]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.shadowColor = args[0]
  },
  [Canvas2DCommands.SET_SHADOW_OFFSET_X]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.shadowOffsetX = args[0]
  },
  [Canvas2DCommands.SET_SHADOW_OFFSET_Y]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.shadowOffsetY = args[0]
  },
  [Canvas2DCommands.SET_STROKE_STYLE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.strokeStyle = args[0]
  },
  [Canvas2DCommands.SET_STROKE_STYLE_BY_PATTERN]: (ctx: CanvasRenderingContext2D, args: any) => {
    const pattern = ctx.createPattern.apply(ctx, args)
    pattern && (ctx.strokeStyle = pattern)
  },
  [Canvas2DCommands.SET_STROKE_STYLE_BY_LINEAR_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 4
    const gradient = ctx.createLinearGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.strokeStyle = gradient
  },
  [Canvas2DCommands.SET_STROKE_STYLE_BY_RADIAL_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 6
    const gradient = ctx.createRadialGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.strokeStyle = gradient
  },
  [Canvas2DCommands.SET_STROKE_STYLE_BY_CONIC_GRADIENT]: (
    ctx: CanvasRenderingContext2D,
    args: any
  ) => {
    const end = 3
    const gradient = ctx.createConicGradient.apply(ctx, args.slice(0, end))
    const stopCount = args[end]
    if (stopCount > 0) {
      let j = end + 1
      for (let i = 0; i < stopCount; i++) {
        const stopArgs = args.slice(j, (j += 2))
        gradient.addColorStop.apply(gradient, stopArgs)
      }
    }
    ctx.strokeStyle = gradient
  },
  [Canvas2DCommands.SET_TEXT_ALIGN]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.textAlign = args[0]
  },
  [Canvas2DCommands.SET_TEXT_BASELINE]: (ctx: CanvasRenderingContext2D, args: any) => {
    ctx.textBaseline = args[0]
  }
}

export function useCanvas2D(ctx: Ref<CanvasRenderingContext2D | null | undefined>) {
  return {
    exec: (commands: any) => {
      if (!ctx.value) {
        return
      }
      commands.forEach(command => {
        const [cmd, ...args] = command
        const fn = defineCommands[cmd]
        if (fn) {
          fn(ctx.value, args)
        } else {
          console.log(command)
        }
      })
    }
  }
}
