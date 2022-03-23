const builtInComponentTags: string[] = [
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
]

export function isBuiltInComponent(tag: string) {
  return builtInComponentTags.includes(tag)
}
