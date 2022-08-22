import { defineComponent, PropType, ref, watch, computed, nextTick } from "vue"
import { EvokerElement } from "../../../dom/element"
import { addClickEvent } from "../../../dom/event"
import { useHover } from "../../composables/useHover"
import { dispatchEvent } from "../../../dom/event"
import { getUserInfo } from "../../../bridge/api/open"
import Loading from "../loading"
import { JSBridge } from "../../../bridge"

const enum OpenTypes {
  GET_USER_INFO = "getUserInfo",
  OPEN_SETTING = "openSetting",
  SHARE = "share"
}

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
    default: "ek-button--hover"
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
    type: String as PropType<OpenTypes.GET_USER_INFO | OpenTypes.OPEN_SETTING | OpenTypes.SHARE>,
    required: false
  }
}

export default defineComponent({
  name: "ek-button",
  props,
  emits: ["getuserinfo"],
  setup(props, { emit, expose }) {
    const container = ref<HTMLElement>()

    const { finalHoverClass } = useHover(container, props)

    const classes = computed(() => {
      let cls = "ek-button "
      cls += `ek-button--${props.type} `
      cls += `ek-button--size-${props.size} `
      if (props.disabled) {
        cls += "ek-button--disabled "
      }
      if (props.plain) {
        cls += `ek-button--${props.type}--plain `
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
        if (parent.tagName === "EK-FORM") {
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
        case OpenTypes.GET_USER_INFO:
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
        case OpenTypes.OPEN_SETTING:
          JSBridge.invoke(OpenTypes.OPEN_SETTING)
          break
        case OpenTypes.SHARE:
          const button = container.value!
          const target = {
            id: button.id,
            offsetLeft: button.offsetLeft,
            offsetTop: button.offsetTop
          }
          JSBridge.invoke("shareAppMessage", { target })
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

    const validOpenType = (type?: OpenTypes) => {
      return (
        type && [OpenTypes.GET_USER_INFO, OpenTypes.OPEN_SETTING, OpenTypes.SHARE].includes(type)
      )
    }

    watch(
      () => props.openType,
      openType => {
        builtInClickEvent && builtInClickEvent()
        if (validOpenType(openType)) {
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
      <ek-button ref={container} class={classes.value} style={styleses.value}>
        <div class="ek-button__content">
          {renderLoading()}
          <div class="ek-button__text"></div>
        </div>
      </ek-button>
    )
  }
})
