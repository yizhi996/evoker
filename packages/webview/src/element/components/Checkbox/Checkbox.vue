<template>
  <nz-checkbox v-tap.stop="onClick" :class="disabled ? 'nz-checkbox--disabled' : ''">
    <icon :type="checked ? 'success' : 'circle'" :color="color" />
    <span class="nz-checkbox__label">
      <slot></slot>
    </span>
  </nz-checkbox>
</template>

<script setup lang="ts">
import { nextTick, watch, onMounted, getCurrentInstance } from "vue"
import Icon from "../Icon.vue"
import { vTap } from "../../directive/tap"
import { useParent, ParentProvide } from "../../use/useRelation"
import { CHECKBOX_GROUP_KEY, CheckboxProvide } from "./constant"

const props = withDefaults(defineProps<{
  value?: string
  checked?: boolean
  disabled?: boolean
  color?: string
}>(), {
  checked: false,
  disabled: false,
  color: "#1989fa"
})

const instance = getCurrentInstance()!

let group: ParentProvide<CheckboxProvide> | undefined

onMounted(() => {
  nextTick(() => {
    group = useParent(instance, CHECKBOX_GROUP_KEY)
    onChecked(false)
  })
})

watch(() => props.checked, () => {
  onChecked(false)
})

const onClick = () => {
  if (props.disabled) {
    return
  }
  instance.props.checked = !instance.props.checked
  onChecked(true)
}

const onChecked = (dispatch: boolean) => {
  props.value && group && group.onChecked(props.value, props.checked, dispatch)
}

defineExpose({
  value: props.value,
  getChecked: () => {
    return props.checked
  },
  setChecked: (checked: boolean) => {
    instance.props.checked = checked
  },
  onTapLabel: () => {
    onClick()
  }
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
    margin-left: 5px;
    color: #323233;
    line-height: 20px;
  }

  &--disabled {
    opacity: 0.5;
  }
}
</style>
