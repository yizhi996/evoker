<template>
  <nz-picker-view ref="containerRef">
    <div class="nz-picker-view__wrapper"></div>
  </nz-picker-view>
</template>

<script setup lang="ts">
import { getCurrentInstance, ref, watch } from "vue"
import { PICKER_VIEW_KEY } from "./define"
import { useChildren } from "../../use/useRelation"

const instance = getCurrentInstance()!

const emit = defineEmits(["pickstart", "pickend", "change"])

const props = withDefaults(
  defineProps<{
    value: number[]
    indicatorStyle?: string
    indicatorClass?: string
    maskStyle?: string
    maskClass?: string
  }>(),
  {
    value: () => []
  }
)

const containerRef = ref<HTMLElement>()

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
      exposed.setHeight(containerRef.value!.offsetHeight)
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
      exposed.setHeight(containerRef.value!.offsetHeight)
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
      exposed.setHeight(containerRef.value!.offsetHeight)
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
</script>

<style lang="less">
nz-picker-view {
  display: block;
}

.nz-picker-view {
  &__wrapper {
    display: flex;
    position: relative;
    overflow: hidden;
    height: 100%;
  }
}
</style>
