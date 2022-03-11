<template>
  <nz-radio ref="containerRef" v-tap.stop="onClick" :class="disabled ? 'nz-radio--disabled' : ''">
    <slot name="icon">
      <icon :type="checked ? 'success' : 'circle'" :color="checkedColor" />
    </slot>
    <span class="nz-radio__label">
      <slot></slot>
    </span>
  </nz-radio>
</template>

<script setup lang="ts">
import { ref, nextTick, onMounted, getCurrentInstance } from "vue"
import { extend } from "@vue/shared"
import Icon from "../Icon.vue"
import { vTap } from "../../directive/tap"
import { useParent } from "../../use/useRelation"
import { RADIO_GROUP_KEY, RadioProvide } from "./constant"

const props = withDefaults(defineProps<{
  name: unknown
  checkedColor?: string
  disabled?: boolean
}>(), {
  checkedColor: "#1989fa",
  disabled: false
})

const emit = defineEmits(["update:modelValue", "click"])

const instance = getCurrentInstance()!

const containerRef = ref<HTMLElement>()
let group: RadioProvide | null

const checked = ref(false)

onMounted(() => {
  nextTick(() => {
    const { parent } = useParent(instance, RADIO_GROUP_KEY)
    group = parent
  })
})

const onClick = () => {
  if (props.disabled) {
    return
  }
  group && setGroupChecked()
  emit("click")
}

const setGroupChecked = () => {
  group && group.updateGroupChecked(props.name)
}

extend(instance.proxy, {
  childName: props.name,
  checked,
})
</script>

<style lang="less">
nz-radio {
  display: flex;
  align-items: center;
  overflow: hidden;
}

.nz-radio {
  &__label {
    margin-left: 8px;
    color: #323233;
    line-height: 20px;
  }

  &--disabled {
    opacity: 0.5;
  }
}
</style>
