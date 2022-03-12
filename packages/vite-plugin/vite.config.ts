import { defineConfig } from "vite"
import { resolve } from "path"

const pkg = require(resolve(__dirname, `package.json`))

// https://vitejs.dev/config/
export default defineConfig(({ mode }) => {
  return {
    build: {
      lib: {
        entry: resolve(__dirname, "src/index.ts"),
        name: pkg.buildOptions?.name,
        fileName: foramt => `vite-plugin.${foramt}.js`,
        formats: ["cjs", "es"]
      },
      rollupOptions: {
        external: [
          "ws",
          "zlib",
          "path",
          "fs",
          "os",
          "crypto",
          "archiver",
          "tmp",
          "vue",
          "@vitejs/plugin-vue",
          "@vue/compiler-core",
          "rollup-plugin-copy",
          "picocolors"
        ]
      }
    }
  }
})
