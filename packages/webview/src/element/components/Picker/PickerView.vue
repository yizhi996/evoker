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

const props = withDefaults(defineProps<{
  value: number[]
  indicatorStyle?: string
  indicatorClass?: string
  maskStyle?: string
  maskClass?: string
}>(), {
  value: () => [],
})

const containerRef = ref<HTMLElement>()

const { children, linkChildren } = useChildren(instance, PICKER_VIEW_KEY)
linkChildren()

watch(() => [...children], () => {
  children.forEach((child, i) => {
    if (child.$.exposed) {
      child.$.exposed.setIndicatorStyle(props.indicatorStyle)
      child.$.exposed.setIndicatorClass(props.indicatorClass)
      child.$.exposed.setMaskStyle(props.maskStyle)
      child.$.exposed.setMaskClass(props.maskClass)
      child.$.exposed.setHeight(containerRef.value!.offsetHeight)
      child.$.exposed.setValue(props.value[i])
    }
  })
})

watch(() => props.indicatorStyle, () => {
  children.forEach((child, i) => {
    if (child.$.exposed) {
      child.$.exposed.setIndicatorStyle(props.indicatorStyle)
      child.$.exposed.setHeight(containerRef.value!.offsetHeight)
      child.$.exposed.setValue(props.value[i])
    }
  })
})

watch(() => props.indicatorClass, () => {
  children.forEach((child, i) => {
    if (child.$.exposed) {
      child.$.exposed.setIndicatorClass(props.indicatorClass)
      child.$.exposed.setHeight(containerRef.value!.offsetHeight)
      child.$.exposed.setValue(props.value[i])
    }
  })
})

watch(() => props.maskStyle, () => {
  children.forEach((child) => {
    if (child.$.exposed) {
      child.$.exposed.setMaskStyle(props.maskStyle)
    }
  })
})

watch(() => props.maskClass, () => {
  children.forEach((child) => {
    if (child.$.exposed) {
      child.$.exposed.setMaskClass(props.maskClass)
    }
  })
})

watch(() => [...props.value], () => {
  children.forEach((child, i) => {
    if (child.$.exposed) {
      child.$.exposed.setValue(props.value[i])
    }
  })
})

const onChange = () => {
  const value = children.map(child => {
    return child.$.exposed!.getCurrent()
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