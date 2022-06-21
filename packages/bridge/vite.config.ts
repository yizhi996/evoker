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
        fileName: foramt => `bridge${foramt === "es" ? ".esm-bundler" : ""}.js`,
        formats: ["es"]
      },
      rollupOptions: {
        external: ["vue", "@nzoth/shared"]
      }
    }
  }
})
