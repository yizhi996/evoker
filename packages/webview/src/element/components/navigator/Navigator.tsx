import { defineComponent, PropType, withDirectives, VNode } from "vue"
import { vTap } from "../../directive/tap"
import {
  navigateTo,
  redirectTo,
  switchTab,
  reLaunch,
  navigateBack,
  navigateToMiniProgram,
  exit
} from "../../../bridge"

const props = {
  target: { type: String as PropType<"self" | "miniProgram">, default: "self" },
  url: { type: String, required: false },
  openType: {
    type: String as PropType<
      "navigate" | "redirect" | "switchTab" | "reLaunch" | "navigateBack" | "exit"
    >,
    default: "navigate"
  },
  delta: { type: Number, default: 1 },
  appId: { type: String, required: false },
  path: { type: String, required: false }
}

export default defineComponent({
  name: "ek-navigator",
  props,
  setup(props) {
    const invoke = () => {
      if (props.target === "self") {
        switch (props.openType) {
          case "navigate":
            navigateTo(props.url)
            break
          case "redirect":
            redirectTo(props.url)
            break
          case "switchTab":
            switchTab(props.url)
            break
          case "reLaunch":
            reLaunch(props.url)
            break
          case "navigateBack":
            navigateBack(props.delta)
            break
        }
      } else if (props.target === "miniProgram") {
        if (props.openType === "navigate") {
          if (props.appId) {
            navigateToMiniProgram({ appId: props.appId, path: props.path })
          }
        } else if (props.openType === "exit") {
          exit()
        } else {
          console.warn("target required: miniProgram")
        }
      }
    }

    return () => {
      return withDirectives((<ek-navigator></ek-navigator>) as VNode, [[vTap, invoke]])
    }
  }
})
