import vuePlugin from "@vitejs/plugin-vue"
import type { Options as VueOptions } from "@vitejs/plugin-vue"
import { isHTMLTag, isSVGTag } from "@vue/shared"
import compiler, { baseParse } from "@vue/compiler-core"
import type { RootNode, CompilerOptions } from "@vue/compiler-core"

const builtInComponentTags = new Set([
  "view",
  "image",
  "button",
  "input",
  "switch",
  "slider",
  "checkbox",
  "checkbox-group",
  "movable-area",
  "movable-view",
  "navigator",
  "scroll-view",
  "progress",
  "textarea",
  "swiper",
  "swiper-item",
  "camera",
  "video",
  "icon",
  "radio",
  "radio-group",
  "map",
  "picker",
  "picker-view",
  "picker-view-column",
  "from",
  "canvas",
  "label"
])

function isBuiltInComponent(tag: string) {
  return builtInComponentTags.has(tag)
}

export function vue(options: VueOptions) {
  const vueOptions: VueOptions = {
    template: {
      compilerOptions: {
        isNativeTag: tag => {
          return isHTMLTag(tag) || isSVGTag(tag) || isBuiltInComponent(tag)
        }
      },
      transformAssetUrls: { image: ["src"] },
      compiler: {
        compile: (template: string | RootNode, options?: CompilerOptions | undefined) => {
          // disabled createStaticVNode
          options && (options.transformHoist = null)
          return compiler.baseCompile(template, options)
        },
        parse: baseParse
      },
      ...options?.template
    },
    ...options
  }

  return vuePlugin(vueOptions)
}
