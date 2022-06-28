import { defineComponent, getCurrentInstance, PropType, ref, watch } from "vue"
import { PICKER_VIEW_KEY } from "./define"
import { useChildren } from "../../composables/useRelation"

const props = {
  value: { type: Array as PropType<number[]>, default: () => [] },
  indicatorStyle: { type: String, required: false },
  indicatorClass: { type: String, required: false },
  maskStyle: { type: String, required: false },
  maskClass: { type: String, required: false }
}

export default defineComponent({
  name: "ev-picker-view",
  props,
  emits: ["pickstart", "pickend", "change"],
  setup(props, { emit, expose }) {
    const instance = getCurrentInstance()!

    const container = ref<HTMLElement>()

    const { children, linkChildren } = useChildren(PICKER_VIEW_KEY)
    linkChildren({})

    watch(
      () => [...children],
      () => {
        children.forEach((child, i) => {
          const exposed = child.exposed!
          exposed.setIndicatorStyle(props.indicatorStyle)
          exposed.setIndicatorClass(props.indicatorClass)
          exposed.setMaskStyle(props.maskStyle)
          exposed.setMaskClass(props.maskClass)
          exposed.setHeight(container.value!.offsetHeight)
          exposed.setValue(props.value[i])
        })
      }
    )

    watch(
      () => props.indicatorStyle,
      () => {
        children.forEach((child, i) => {
          const exposed = child.exposed!
          exposed.setIndicatorStyle(props.indicatorStyle)
          exposed.setHeight(container.value!.offsetHeight)
          exposed.setValue(props.value[i])
        })
      }
    )

    watch(
      () => props.indicatorClass,
      () => {
        children.forEach((child, i) => {
          const exposed = child.exposed!
          exposed.setIndicatorClass(props.indicatorClass)
          exposed.setHeight(container.value!.offsetHeight)
          exposed.setValue(props.value[i])
        })
      }
    )

    watch(
      () => props.maskStyle,
      () => {
        children.forEach(child => {
          const exposed = child.exposed!
          exposed.setMaskStyle(props.maskStyle)
        })
      }
    )

    watch(
      () => props.maskClass,
      () => {
        children.forEach(child => {
          const exposed = child.exposed!
          exposed.setMaskClass(props.maskClass)
        })
      }
    )

    watch(
      () => [...props.value],
      () => {
        children.forEach((child, i) => {
          const exposed = child.exposed!
          exposed.setValue(props.value[i])
        })
      }
    )

    const onChange = () => {
      const value = children.map(child => {
        return child.exposed!.getCurrent()
      })
      instance.props.value = value
      emit("change", { value })
    }

    const onPickStart = () => {
      emit("pickstart", {})
    }

    const onPickEnd = () => {
      emit("pickend", {})
    }

    linkChildren({
      onChange,
      onPickStart,
      onPickEnd
    })

    return () => (
      <ev-picker-view ref={container}>
        <div class="ev-picker-view__wrapper"></div>
      </ev-picker-view>
    )
  }
})
