import { invokeWebViewMethod } from "../../../fromWebView"
import { CanvasRenderingContext2D } from "./context"
import { Image, ImageData } from "./image"

const canvasContexts = new Map<number, CanvasRenderingContext2D>()

const FPS_60 = 1000 / 60

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

  private _width: number

  private _height: number

  private requestId: number = 0

  private frames = new Map<number, NodeJS.Timeout>()

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

  createImage(): Image {
    return new Image()
  }

  createImageData(width: number, height: number): ImageData {
    return new ImageData(width, height)
  }

  requestAnimationFrame(callback: () => void) {
    const id = this.requestId++
    this.frames.set(
      id,
      setTimeout(() => {
        callback && callback()
        this.frames.delete(id)
      }, FPS_60)
    )
    return id
  }

  cancelAnimationFrame(requestId: number) {
    const timer = this.frames.get(requestId)
    if (timer) {
      clearTimeout(timer)
      this.frames.delete(requestId)
    }
  }
}

export function createCanvasNodeInstance(node: CanvasNodeInfo) {
  return new CanvasNode(node)
}
