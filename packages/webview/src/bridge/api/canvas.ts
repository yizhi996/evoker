import { isEvokerElement, nodes } from "../../dom/element"

interface ExecCanvasCommandOptions {
  nodeId: number
  commands: any[]
}

export function execCanvasCommand(options: ExecCanvasCommandOptions) {
  const node = nodes.get(options.nodeId)
  if (node && isEvokerElement(node.el)) {
    node.el.__instance!.exposed!.exec(options)
  }
  return Promise.resolve({})
}

interface OperateCanvasOptions {
  nodeId: number
  method: string
  data: Record<string, any>
}

export function operateCanvas(options: OperateCanvasOptions) {
  const node = nodes.get(options.nodeId)
  if (node && isEvokerElement(node.el)) {
    node.el.__instance!.exposed!.operate(options)
  }
  return Promise.resolve({})
}
