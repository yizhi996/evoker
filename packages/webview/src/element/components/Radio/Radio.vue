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
import Icon from "../Icon.vue"
import { vTap } from "../../directive/tap"
import { useParent, ParentProvide } from "../../use/useRelation"
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
let group: ParentProvide<RadioProvide> | undefined

const checked = ref(false)

onMounted(() => {
  nextTick(() => {
    group = useParent(instance, RADIO_GROUP_KEY)
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

defineExpose({
  childName: props.name,
  setChecked: (value: boolean) => {
    checked.value = value
  },
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
