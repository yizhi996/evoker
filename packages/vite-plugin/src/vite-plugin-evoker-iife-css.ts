import { Plugin, ResolvedConfig } from "vite"
import { transform } from "esbuild"

let config: ResolvedConfig

interface Options {
  cssFilename: string
  targetFilename: string
}

export function vitePluginEvokerIIFECSS(options: Options): Plugin {
  return {
    apply: "build",

    enforce: "post",

    name: "vite:evoker-iife-css",

    configResolved(reslovedConfig) {
      config = reslovedConfig
    },

    async generateBundle(opts, bundle) {
      const css = bundle[options.cssFilename]
      if (css) {
        delete bundle[options.cssFilename]

        // @ts-ignore
        const { code } = await transform(css.source, {
          loader: "css",
          minify: true,
          target: config.build.cssTarget || undefined
        })

        const IIFE_CSS = `
        (function() {
            try {
                const style = document.createElement('style')
                style.innerHTML = ${JSON.stringify(code)}
                document.head.appendChild(style)
            } catch(error) {
              console.error(error)
            }
        })();
        `
        // @ts-ignore
        bundle[options.targetFilename].code += IIFE_CSS
      }
    }
  }
}
