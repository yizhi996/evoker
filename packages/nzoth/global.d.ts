import { nz as NZothGlobal } from "./src/index"

declare global {
  const nz: typeof NZothGlobal
}
