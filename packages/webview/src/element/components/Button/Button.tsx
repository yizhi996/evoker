import { defineComponent, PropType, ref, watch, computed, nextTick } from "vue"
import { EvokerElement } from "../../../dom/element"
import { addClickEvent } from "../../../dom/event"
import { isTrue } from "../../../utils"
import { useHover } from "../../composables/useHover"
import { dispatchEvent } from "../../../dom/event"
import { getUserInfo } from "../../../bridge/api/open"
import Loading from "../loading"

const props = {
  type: {
    type: String as PropType<"primary" | "default" | "warn" | "success" | "danger">,
    default: "default"
  },
  size: {
    type: String as PropType<"default" | "mini" | "large" | "small">,
    default: "default"
  },
  color: {
    type: String,
    default: ""
  },
  plain: {
    type: Boolean,
    default: false
  },
  disabled: {
    type: Boolean,
    default: false
  },
  loading: {
    type: Boolean,
    default: false
  },
  hoverClass: {
    type: String,
    default: "ev-button--hover"
  },
  hoverStopPropagation: {
    type: Boolean,
    default: false
  },
  hoverStartTime: {
    type: Number,
    default: 20
  },
  hoverStayTime: {
    type: Number,
    default: 70
  },
  formType: {
    type: String as PropType<"submit" | "reset">,
    required: false
  },
  openType: {
    type: String as PropType<"getUserInfo" | "openSetting">,
    required: false
  }
}

export default defineComponent({
  name: "ev-button",
  props,
  emits: ["getuserinfo"],
  setup(props, { emit, expose }) {
    const container = ref<HTMLElement>()

    const { finalHoverClass } = useHover(container, props)

    const classes = computed(() => {
      let cls = "ev-button "
      cls += `ev-button--${props.type} `
      cls += `ev-button--size-${props.size} `
      if (isTrue(props.disabled)) {
        cls += "ev-button--disabled "
      }
      if (props.plain) {
        cls += `ev-button--${props.type}--plain `
      }
      cls += `${finalHoverClass.value}`
      return cls
    })

    const styleses = computed(() => {
      let style = ""
      if (props.color) {
        style += props.plain ? `color: ${props.color};` : `background-color: ${props.color};`
        style += `border: 1px solid ${props.color};`
      }
      return style
    })

    const findForm = (el: HTMLElement): EvokerElement | undefined => {
      const parent = el.parentElement
      if (parent) {
        if (parent.tagName === "EV-FORM") {
          return parent as EvokerElement
        }
        return findForm(parent)
      }
    }

    const onTapForm = () => {
      const form = findForm(container.value!)
      if (form) {
        const { onSubmit, onReset } = form.__instance.exposed!
        if (props.formType === "submit") {
          onSubmit()
        } else if (props.formType === "reset") {
          onReset()
        }
      }
    }

    const onTapOpenType = () => {
      switch (props.openType) {
        case "getUserInfo":
          getUserInfo({
            withCredentials: true,
            success: res => {
              emit("getuserinfo", res)
            },
            fail: res => {
              emit("getuserinfo", res)
            }
          })
          break
      }
    }

    const builtInClick = () => {
      if (props.openType) {
        onTapOpenType()
      } else if (props.formType) {
        onTapForm()
      }
    }

    let builtInClickEvent: Function

    watch(
      () => props.formType,
      formType => {
        builtInClickEvent && builtInClickEvent()
        if (formType === "submit" || formType === "reset") {
          nextTick(() => {
            if (container.value) {
              builtInClickEvent = addClickEvent(container.value, builtInClick)
            }
          })
        }
      },
      {
        immediate: true
      }
    )

    watch(
      () => props.openType,
      openType => {
        builtInClickEvent && builtInClickEvent()
        if (openType && ["getUserInfo", "openSetting"].includes(openType)) {
          nextTick(() => {
            if (container.value) {
              builtInClickEvent = addClickEvent(container.value, builtInClick)
            }
          })
        }
      },
      {
        immediate: true
      }
    )

    expose({
      onTapLabel: () => {
        if (props.formType === "submit" || props.formType === "reset") {
          onTapForm()
        } else {
          const nodeId = (container.value as EvokerElement).__nodeId
          dispatchEvent(nodeId, {
            type: "click",
            args: []
          })
        }
      }
    })

    const renderLoading = () => {
      if (props.loading) {
        return <Loading style="margin-right: 5px" />
      }
    }

    return () => (
      <ev-button ref={container} class={classes.value} style={styleses.value}>
        <div class="ev-button__content">
          {renderLoading()}
          <div class="ev-button__text"></div>
        </div>
      </ev-button>
    )
  }
})
