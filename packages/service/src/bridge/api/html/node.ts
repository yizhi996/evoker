import { CanvasRenderingContext2D } from "./canvas"

export function createCanvasNode(
  nodeId: number,
  canvasType: "2d" | "webgl",
  canvasId: number
) {
  return new CanvasNode(nodeId, canvasType, canvasId)
}

class CanvasNode {
  nodeId: number

  canvasType: "2d" | "webgl"

  canvasId: number

  _width: number = 0
  _height: number = 0

  constructor(nodeId: number, canvasType: "2d" | "webgl", canvasId: number) {
    this.nodeId = nodeId
    this.canvasType = canvasType
    this.canvasId = canvasId
  }

  get width() {
    return this._width
  }

  set width(newValue) {
    this._width = newValue
  }

  get height() {
    return this._height
  }

  set height(newValue) {
    this._height = newValue
  }

  getContext(type: "2d" | "webgl") {
    if (type === "2d") {
      return new CanvasRenderingContext2D(this.canvasId)
    }
    return undefined
  }
}
