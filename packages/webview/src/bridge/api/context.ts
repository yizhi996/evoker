import { isEvokerElement, nodes } from "../../dom/element"

interface OperateContextOptions {
  nodeId: number
  method: string
  data: Record<string, any>
}

export function operateContext(options: OperateContextOptions) {
  const node = nodes.get(options.nodeId)
  if (node && isEvokerElement(node.el)) {
    node.el.__instance!.exposed!.operate(options)
  }
  return Promise.resolve({})
}
