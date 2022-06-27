import { getViteConfig } from "../../scripts/utils"

export default getViteConfig("nzoth", {
  external: ["vue"],
  output: {
    globals: {
      vue: "Vue"
    }
  }
})
