import { NZothPage } from "./page"
import { NZothNode } from "./node"

export class NZothComment extends NZothNode {
  data: string

  constructor(data: string, page: NZothPage) {
    super(page)

    this.data = data
  }
}
