import { invokeWebViewMethod } from "../../../fromWebView"
import { CanvasRenderingContext2D } from "./context"

const canvasContexts = new Map<number, CanvasRenderingContext2D>()

export interface CanvasNodeInfo {
  nodeId: number
  tagName: string
  canvasId: number
  webViewId: number
  width: number
  height: number
}

const enum Methods {
  SET_WIDTH = "SET_WIDTH",
  SET_HEIGHT = "SET_HEIGHT"
}

export class CanvasNode {
  nodeId: number

  id: number

  webViewId: number

  _width: number

  _height: number

  constructor(node: CanvasNodeInfo) {
    this.nodeId = node.nodeId
    this.id = node.canvasId
    this.webViewId = node.webViewId
    this._width = node.width
    this._height = node.height
  }

  private operate(method: Methods, data: Record<string, any>) {
    invokeWebViewMethod(
      "operateCanvas",
      { nodeId: this.nodeId, method, data },
      undefined,
      this.webViewId
    )
  }

  get width() {
    return this._width
  }

  set width(newValue) {
    this._width = newValue
    this.operate(Methods.SET_WIDTH, { value: this._width })
  }

  get height() {
    return this._height
  }

  set height(newValue) {
    this._height = newValue
    this.operate(Methods.SET_HEIGHT, { value: this._height })
  }

  getContext(type: "2d" | "webgl") {
    if (type === "2d") {
      let ctx = canvasContexts.get(this.id)
      if (!ctx) {
        ctx = new CanvasRenderingContext2D(this.id, this.nodeId, this.webViewId)
        canvasContexts.set(this.id, ctx)
      }
      return ctx
    }
  }
}

export function createCanvasNodeInstance(node: CanvasNodeInfo) {
  return new CanvasNode(node)
}
