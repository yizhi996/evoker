import { defineConfig } from "vite"
import { resolve } from "path"

const pkg = require(resolve(__dirname, `package.json`))

// https://vitejs.dev/config/
export default defineConfig(() => {
  return {
    build: {
      lib: {
        entry: resolve(__dirname, "src/index.ts"),
        name: pkg.buildOptions?.name,
        fileName: foramt => `service.${foramt === "es" ? "esm-bundler" : "cjs"}.js`,
        formats: ["es", "cjs"]
      },
      rollupOptions: {
        external: ["vue"],
        output: {
          globals: {
            vue: "Vue"
          }
        }
      }
    }
  }
})
