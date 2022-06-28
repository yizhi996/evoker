import { getViteConfig } from "../../scripts/utils"

export default getViteConfig("evoker", {
  external: ["vue"],
  output: {
    globals: {
      vue: "Vue"
    }
  }
})
