<template>
  <nz-checkbox
    ref="containerRef"
    v-tap.stop="onClick"
    :class="disabled ? 'nz-checkbox--disabled' : ''"
  >
    <icon :type="checked ? 'success' : 'circle'" :color="color" />
    <span class="nz-checkbox__label">
      <slot></slot>
    </span>
  </nz-checkbox>
</template>

<script setup lang="ts">
import { ref, nextTick, watch, onMounted, getCurrentInstance } from "vue"
import { extend } from "@vue/shared"
import Icon from "../Icon.vue"
import { vTap } from "../../directive/tap"
import { useParent } from "../../use/useRelation"
import { CHECKBOX_GROUP_KEY, CheckboxProvide } from "./constant"

const props = withDefaults(defineProps<{
  modelValue?: boolean
  name?: unknown
  color?: string
  disabled?: boolean
}>(), {
  modelValue: false,
  color: "#1989fa",
  disabled: false
})

const emit = defineEmits(["update:modelValue", "change"])

const instance = getCurrentInstance()!

const containerRef = ref<HTMLElement>()

let group: CheckboxProvide | null = null

const checked = ref(false)

watch(() => props.modelValue, (value) => {
  checked.value = value
}, {
  immediate: true
})

onMounted(() => {
  nextTick(() => {
    const { parent } = useParent(instance, CHECKBOX_GROUP_KEY)
    group = parent
  })
})

const onClick = () => {
  if (props.disabled) {
    return
  }
  if (group) {
    group.updateGroupChecked(props.name)
  } else {
    instance.props.modelValue = !props.modelValue
    emitChange(instance.props.modelValue as boolean)
  }
}

extend(instance.proxy, {
  childName: props.name,
  checked,
})

const formData = () => {
  return props.modelValue
}

const resetFormData = () => {
  if (group) {
    return
  }
  instance.props.modelValue = false
  emitChange(instance.props.modelValue as boolean)
}

const emitChange = (value: boolean) => {
  emit("update:modelValue", value)
  emit("change", value)
}

defineExpose({
  group,
  formData,
  resetFormData
})

</script>

<style lang="less">
nz-checkbox {
  display: flex;
  align-items: center;
  overflow: hidden;
}

.nz-checkbox {
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
