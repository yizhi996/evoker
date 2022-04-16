import { defineConfig } from "vite"
import { resolve } from "path"

const pkg = require(resolve(__dirname, `package.json`))

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    build: {
      minify: mode === "development" ? false : "terser",
      lib: {
        entry: resolve(__dirname, "src/index.ts"),
        name: pkg.buildOptions?.name,
        fileName: foramt => `bridge.${foramt}.js`,
        formats: ["cjs", "es"]
      },
      rollupOptions: {
        external: ["vue", "@nzoth/shared"]
      }
    }
  }
})
