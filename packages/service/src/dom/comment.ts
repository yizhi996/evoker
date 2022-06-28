import { EvokerPage } from "./page"
import { EvokerNode } from "./node"

export class EvokerComment extends EvokerNode {
  data: string

  constructor(data: string, page: EvokerPage) {
    super(page)

    this.data = data
  }
}
