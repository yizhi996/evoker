<template>
  <nz-radio v-tap.stop="onClick" :class="disabled ? 'nz-radio--disabled' : ''">
    <icon :type="checked ? 'success' : 'circle'" :color="color" />
    <span class="nz-radio__label">
      <slot></slot>
    </span>
  </nz-radio>
</template>

<script setup lang="ts">
import { watch, nextTick, onMounted, getCurrentInstance } from "vue"
import Icon from "../Icon.vue"
import { vTap } from "../../directive/tap"
import { useParent, ParentProvide } from "../../use/useRelation"
import { RADIO_GROUP_KEY, RadioProvide } from "./constant"

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

let group: ParentProvide<RadioProvide> | undefined

onMounted(() => {
  nextTick(() => {
    group = useParent(instance, RADIO_GROUP_KEY)
    props.checked && onChecked(false)
  })
})

watch(() => props.checked, () => {
  props.checked && onChecked(false)
})

const onClick = () => {
  if (props.disabled) {
    return
  }
  !props.checked && onChecked(true)
}

const onChecked = (dispatch: boolean) => {
  props.value && group && group.onChecked(props.value, dispatch)
}

defineExpose({
  value: props.value,
  getChecked: () => {
    return props.checked
  },
  setChecked: (checked: boolean) => {
    instance.props.checked = checked
  }
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
    margin-left: 5px;
    color: #323233;
    line-height: 20px;
  }

  &--disabled {
    opacity: 0.5;
  }
}
</style>
