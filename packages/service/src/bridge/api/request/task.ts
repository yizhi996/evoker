import { InnerJSBridge } from "../../bridge"

export class Task {
  readonly taskId: string

  isCancel = false

  constructor(kind: string) {
    this.taskId = `${kind}_${Date.now()}`
  }

  /** 中断请求任务 */
  abort() {
    this.isCancel = true
    InnerJSBridge.invoke("cancelRequest", { taskId: this.taskId })
  }
}
