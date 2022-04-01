<template>
  <div class="mx-2.5 mt-2.5">
    <n-topic>{{ checked }}</n-topic>
    <radio-group class="mt-2.5" @change="onChange">
      <n-cell-group>
        <n-cell v-for="fruit of fruits" :key="fruit.value">
          <radio
            class="w-full h-full"
            :value="fruit.value"
            :checked="fruit.checked"
          >{{ fruit.name }}</radio>
        </n-cell>
      </n-cell-group>
    </radio-group>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"


const fruits = reactive([
  { name: "苹果", value: "apple" },
  { name: "香蕉", value: "banana" },
  { name: "菠萝", value: "pineapple", checked: true },
  { name: "葡萄", value: "grape" },
  { name: "柠檬", value: "lemon" }
])

const checked = ref("菠萝")

const onChange = ({ value: selected }) => {
  checked.value = fruits.find(item => item.value === selected)!.name
}
</script>
