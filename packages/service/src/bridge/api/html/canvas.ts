import { isString } from "@vue/shared"
import { queuePostFlushCb } from "vue"

class CanvasPattern {
  image: any
  repetition

  constructor(image: any, repetition: "repeat" | "repeat-x" | "repeat-y" | "no-repeat") {
    this.repetition = repetition ?? "repeat"
    this.image = image
  }
}

class CanvasGradient {
  stopCount = 0

  stops: Record<string, any>[] = []

  addColorStop(offset: number, color: string) {
    if (this.stopCount < 5 && 0.0 <= offset && offset <= 1.0) {
      this.stops[this.stopCount] = { offset, color }
      this.stopCount++
    }
  }
}

interface LinearGradientPosition {
  x: number
  y: number
}

class CanvasLinearGradient extends CanvasGradient {
  startPosition: LinearGradientPosition

  endPosition: LinearGradientPosition

  constructor(x0: number, y0: number, x1: number, y1: number) {
    super()

    this.startPosition = { x: x0, y: y0 }
    this.endPosition = { x: x1, y: y1 }
  }
}

interface RadialGradientPosition {
  x: number
  y: number
  r: number
}

class CanvasRadialGradient extends CanvasGradient {
  startPosition: RadialGradientPosition

  endPosition: RadialGradientPosition

  constructor(x0: number, y0: number, r0: number, x1: number, y1: number, r1: number) {
    super()
    this.startPosition = { x: x0, y: y0, r: r0 }
    this.endPosition = { x: x1, y: y1, r: r1 }
  }
}

const enum Canvas2DMethods {
  QuadraticCurveTo = 0
}

export class CanvasRenderingContext2D {
  private commandQueue: any[] = []

  private flush: () => void

  _globalAlpha = 1.0

  _fillStyle: string | CanvasPattern | CanvasGradient = "#000000"

  _strokeStyle: string | CanvasPattern | CanvasGradient = "#000000"

  _shadowColor = "#000000"
  _shadowBlur = 0
  _shadowOffsetX = 0
  _shadowOffsetY = 0
  _lineWidth = 1
  _lineCap = "butt"
  _lineJoin: "round" | "bevel" | "miter" = "miter"
  _lineDash: number[] = []
  _lineDashOffset = 0

  _miterLimit = 10

  _globalCompositeOperation = "source-over"

  _textAlign = "start"
  _textBaseline = "alphabetic"

  _font = "10px sans-serif"

  _savedGlobalAlpha: number[] = []

  timer = null

  canvasId: number

  constructor(canvasId: number) {
    this.canvasId = canvasId

    this.flush = this._flush.bind(this)
  }

  private enqueue(command: any) {
    this.commandQueue.push(command)
    queuePostFlushCb(this.flush)
  }

  private _flush() {
    if (this.commandQueue.length === 0) {
      return
    }
    // Canvas2D.exec(this.commandQueue, this.canvasId)
    this.commandQueue = []
  }

  private bindImageTexture(src: string, id: string) {}

  get fillStyle() {
    return this._fillStyle
  }

  set fillStyle(value) {
    this._fillStyle = value

    if (isString(value)) {
      this.enqueue(["F", value])
    } else if (value instanceof CanvasPattern) {
      const image = value.image
      this.bindImageTexture(image.src, image._id)
      this.enqueue(["G", image._id, value.repetition])
    } else if (value instanceof CanvasLinearGradient) {
      const command = [
        "D",
        value.startPosition.x.toFixed(2),
        value.startPosition.y.toFixed(2),
        value.endPosition.x.toFixed(2),
        value.endPosition.y.toFixed(2),
        value.stopCount
      ]
      value.stops.forEach(stop => {
        command.push(stop.offset)
        command.push(stop.color)
      })
      this.enqueue(command)
    } else if (value instanceof CanvasRadialGradient) {
      const command = [
        "H",
        value.startPosition.x.toFixed(2),
        value.startPosition.y.toFixed(2),
        value.startPosition.r.toFixed(2),
        value.endPosition.x.toFixed(2),
        value.endPosition.y.toFixed(2),
        value.endPosition.r.toFixed(2),
        value.stopCount
      ]
      value.stops.forEach(stop => {
        command.push(stop.offset)
        command.push(stop.color)
      })
      this.enqueue(command)
    }
  }

  get globalAlpha() {
    return this._globalAlpha
  }

  set globalAlpha(value) {
    this._globalAlpha = value
    this.enqueue(["a", value.toFixed(2)])
  }

  get strokeStyle() {
    return this._strokeStyle
  }

  set strokeStyle(value) {
    this._strokeStyle = value

    if (isString(value)) {
      this.enqueue(["S", value])
    } else if (value instanceof CanvasPattern) {
      const image = value.image
      this.bindImageTexture(image.src, image._id)
      this.enqueue(["G", image._id, value.repetition])
    } else if (value instanceof CanvasRadialGradient) {
      const command = [
        "D",
        value.startPosition.x.toFixed(2),
        value.startPosition.y.toFixed(2),
        value.endPosition.x.toFixed(2),
        value.endPosition.y.toFixed(2),
        value.stopCount
      ]
      value.stops.forEach(stop => {
        command.push(stop.offset)
        command.push(stop.color)
      })
      this.enqueue(command)
    } else if (value instanceof CanvasRadialGradient) {
      const command = [
        "H",
        value.startPosition.x.toFixed(2),
        value.startPosition.y.toFixed(2),
        value.startPosition.r.toFixed(2),
        value.endPosition.x.toFixed(2),
        value.endPosition.y.toFixed(2),
        value.endPosition.r.toFixed(2),
        value.stopCount
      ]
      value.stops.forEach(stop => {
        command.push(stop.offset)
        command.push(stop.color)
      })
      this.enqueue(command)
    }
  }

  get shadowColor() {
    return this._shadowColor
  }

  set shadowColor(value) {
    this._shadowColor = value
    this.enqueue(["K", value])
  }

  get shadowBlur() {
    return this._shadowBlur
  }

  set shadowBlur(value) {
    this._shadowBlur = value
    this.enqueue(["Z", value])
  }

  get shadowOffsetX() {
    return this._shadowOffsetX
  }

  set shadowOffsetX(value) {
    this._shadowOffsetX = value
    this.enqueue(["X", value])
  }

  get shadowOffsetY() {
    return this._shadowOffsetY
  }

  set shadowOffsetY(value) {
    this._shadowOffsetY = value
    this.enqueue(["Y", value])
  }

  get lineDashOffset() {
    return this._lineDashOffset
  }

  set lineDashOffset(value) {
    this._lineWidth = value
    this.enqueue(["N", value])
  }

  get lineWidth() {
    return this._lineWidth
  }

  set lineWidth(value) {
    this._lineWidth = value
    this.enqueue(["W", value])
  }

  get lineCap() {
    return this._lineCap
  }

  set lineCap(value) {
    this._lineCap = value
    this.enqueue(["C", value])
  }

  get lineJoin() {
    return this._lineJoin
  }

  set lineJoin(value) {
    this._lineJoin = value
    this.enqueue(["J", value])
  }

  get miterLimit() {
    return this._miterLimit
  }

  set miterLimit(value) {
    this._miterLimit = value
    this.enqueue(["M", value])
  }

  get globalCompositeOperation() {
    return this._globalCompositeOperation
  }

  set globalCompositeOperation(value) {
    this._globalCompositeOperation = value
    let mode = 0
    switch (value) {
      case "source-over":
        mode = 0
        break
      case "source-atop":
        mode = 5
        break
      case "source-in":
        mode = 0
        break
      case "source-out":
        mode = 2
        break
      case "destination-over":
        mode = 4
        break
      case "destination-atop":
        mode = 4
        break
      case "destination-in":
        mode = 4
        break
      case "destination-out":
        mode = 3
        break
      case "lighter":
        mode = 1
        break
      case "copy":
        mode = 2
        break
      case "xor":
        mode = 6
        break
      default:
        mode = 0
    }
    this.enqueue(["B", mode])
  }

  get textAlign() {
    return this._textAlign
  }

  set textAlign(value) {
    this._textAlign = value

    let align = 0
    switch (value) {
      case "start":
        align = 0
        break
      case "end":
        align = 1
        break
      case "left":
        align = 2
        break
      case "center":
        align = 3
        break
      case "right":
        align = 4
        break
      default:
        align = 0
    }

    this.enqueue(["A", align])
  }

  get textBaseline() {
    return this._textBaseline
  }

  set textBaseline(value) {
    this._textBaseline = value

    let baseline = 0
    switch (value) {
      case "alphabetic":
        baseline = 0
        break
      case "middle":
        baseline = 1
        break
      case "top":
        baseline = 2
        break
      case "hanging":
        baseline = 3
        break
      case "bottom":
        baseline = 4
        break
      case "ideographic":
        baseline = 5
        break
      default:
        baseline = 0
        break
    }

    this.enqueue(["E", baseline])
  }

  get font() {
    return this._font
  }

  set font(value) {
    this._font = value
    this.enqueue(["j", value])
  }

  getLineDash() {
    return this._lineDash
  }

  setLineDash(value: number[]) {
    if (Array.isArray(value)) {
      this._lineDash = value
      this.enqueue(["I", value.length, value.join(",")])
    }
  }

  setTransform(a: number, b: number, c: number, d: number, tx: number, ty: number) {
    this.enqueue([
      "t",
      a === 1 ? "1" : a.toFixed(2),
      b === 0 ? "0" : b.toFixed(2),
      c === 0 ? "0" : c.toFixed(2),
      d === 1 ? "1" : d.toFixed(2),
      tx.toFixed(2),
      ty.toFixed(2)
    ])
  }

  transform(a: number, b: number, c: number, d: number, tx: number, ty: number) {
    this.enqueue([
      "f",
      a === 1 ? "1" : a.toFixed(2),
      b === 0 ? "0" : b.toFixed(2),
      c === 0 ? "0" : c.toFixed(2),
      d === 1 ? "1" : d.toFixed(2),
      tx,
      ty
    ])
  }

  resetTransform() {
    this.enqueue(["m"])
  }

  scale(a: number, d: number) {
    this.enqueue(["k", a.toFixed(2), d.toFixed(2)])
  }

  rotate(angle: number) {
    this.enqueue(["r", angle.toFixed(6)])
  }

  translate(tx: number, ty: number) {
    this.enqueue(["l", tx.toFixed(2), ty.toFixed(2)])
  }

  save() {
    this._savedGlobalAlpha.push(this._globalAlpha)
    this.enqueue(["v"])
  }

  restore() {
    this.enqueue(["e"])
    const alpha = this._savedGlobalAlpha.pop()
    if (alpha !== undefined) {
      this._globalAlpha = alpha
    }
  }

  createPattern(image: any, repetition: "repeat" | "repeat-x" | "repeat-y" | "no-repeat") {
    return new CanvasPattern(image, repetition)
  }

  createLinearGradient(x0: number, y0: number, x1: number, y1: number) {
    return new CanvasLinearGradient(x0, y0, x1, y1)
  }

  createRadialGradient = function (
    x0: number,
    y0: number,
    r0: number,
    x1: number,
    y1: number,
    r1: number
  ) {
    return new CanvasRadialGradient(x0, y0, r0, x1, y1, r1)
  }

  strokeRect(x: number, y: number, w: number, h: number) {
    this.enqueue(["s", x, y, w, h])
  }

  clearRect(x: number, y: number, w: number, h: number) {
    this.enqueue(["c", x, y, w, h])
  }

  clip() {
    this.enqueue(["p"])
  }

  resetClip() {
    this.enqueue(["q"])
  }

  closePath() {
    this.enqueue(["o"])
  }

  moveTo(x: number, y: number) {
    this.enqueue(["g", x.toFixed(2), y.toFixed(2)])
  }

  lineTo(x: number, y: number) {
    this.enqueue(["u", x.toFixed(2), y.toFixed(2)])
  }

  quadraticCurveTo(cpx: number, cpy: number, x: number, y: number) {
    this.enqueue([Canvas2DMethods.QuadraticCurveTo, cpx, cpy, x, y])
  }

  bezierCurveTo(cp1x: number, cp1y: number, cp2x: number, cp2y: number, x: number, y: number) {
    this.enqueue([
      "z",
      cp1x.toFixed(2),
      cp1y.toFixed(2),
      cp2x.toFixed(2),
      cp2y.toFixed(2),
      x.toFixed(2),
      y.toFixed(2)
    ])
  }

  arcTo(x1: number, y1: number, x2: number, y2: number, radius: number) {
    this.enqueue(["h", x1, y1, x2, y2, radius])
  }

  beginPath() {
    this.enqueue(["b"])
  }

  fillRect(x: number, y: number, w: number, h: number) {
    this.enqueue(["n", x, y, w, h])
  }

  rect(x: number, y: number, w: number, h: number) {
    this.enqueue(["w", x, y, w, h])
  }

  fill() {
    this.enqueue(["L"])
  }

  stroke(path) {
    this.enqueue(["x"])
  }

  arc(
    x: number,
    y: number,
    radius: number,
    startAngle: number,
    endAngle: number,
    anticlockwise?: boolean
  ) {
    let ianticlockwise = 0
    if (anticlockwise) {
      ianticlockwise = 1
    }

    this.enqueue([
      "y",
      x.toFixed(2),
      y.toFixed(2),
      radius.toFixed(2),
      startAngle,
      endAngle,
      ianticlockwise
    ])
  }

  fillText(text: string, x: number, y: number, maxWidth: number = 0) {
    let tmptext = text.replace(/!/g, "!!")
    tmptext = tmptext.replace(/,/g, "!,")
    tmptext = tmptext.replace(/;/g, "!;")
    this.enqueue(["T", tmptext, x, y, maxWidth])
  }

  strokeText(text: string, x: number, y: number, maxWidth: number = 0) {
    let tmptext = text.replace(/!/g, "!!")
    tmptext = tmptext.replace(/,/g, "!,")
    tmptext = tmptext.replace(/;/g, "!;")
    this.enqueue(["U", tmptext, x, y, maxWidth])
  }

  measureText = function (text: string) {
    throw new Error("not supported yet")
  }

  isPointInPath = function (x: number, y: number) {
    throw new Error("not supported yet")
  }

  drawImage(
    image: any,
    sx: number = 0.0,
    sy: number = 0.0,
    sw?: number,
    sh?: number,
    dx: number = 0.0,
    dy: number = 0.0,
    dw?: number,
    dh?: number
  ) {
    const numArgs = arguments.length

    function drawImageCommands() {
      if (numArgs === 3) {
        return ["d", image._id, image.width, image.height, sx, sy, image.width, image.height]
      } else if (numArgs === 5) {
        return [
          "d",
          image._id,
          image.width,
          image.height,
          sx,
          sy,
          sw || image.width,
          sh || image.height
        ]
      } else if (numArgs === 9) {
        return [
          "d",
          image._id,
          sx,
          sy,
          sw || image.width,
          sh || image.height,
          dx,
          dy,
          dw || image.width,
          dh || image.height
        ]
      }
    }
    this.bindImageTexture(image.src, image._id)
    const command = drawImageCommands()
    command && this.enqueue(command)
  }
}
