import { InnerJSBridge } from "../../bridge"

export class Task {
  taskId: string

  isCancel: boolean = false

  constructor(kind: string) {
    this.taskId = `${kind}_${Date.now()}`
  }

  abort() {
    this.isCancel = true
    InnerJSBridge.invoke("cancelRequest", { taskId: this.taskId })
  }
}
