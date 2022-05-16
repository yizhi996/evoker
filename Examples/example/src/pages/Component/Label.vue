<template>
  <div class="mx-2.5 mt-2.5">
    <n-topic>Checkbox {{ checked1 }}</n-topic>
    <checkbox-group class="mt-2.5" @change="onChangeCheckbox">
      <n-cell-group>
        <n-cell v-for="fruit of fruits" :key="fruit.value">
          <label class="w-full h-full flex items-center">
            <checkbox :value="fruit.value" :checked="fruit.checked"></checkbox>
            <span>{{ fruit.name }}</span>
          </label>
        </n-cell>
      </n-cell-group>
    </checkbox-group>
    <n-topic>Radio for {{ checked2 }}</n-topic>
    <radio-group class="mt-2.5" @change="onChangeRadio">
      <n-cell-group>
        <n-cell v-for="fruit of fruits" :key="fruit.value">
          <radio :id="fruit.value" :value="fruit.value" :checked="fruit.checked"></radio>
          <label class="w-full h-full" :for="fruit.value">{{ fruit.name }}</label>
        </n-cell>
      </n-cell-group>
    </radio-group>
    <n-topic>Switch</n-topic>
    <n-cell-group>
      <n-cell v-for="fruit of fruits" :key="fruit.value">
        <label class="w-full h-full flex items-center">
          <switch :checked="fruit.checked"></switch>
          <span>{{ fruit.name }}</span>
        </label>
      </n-cell>
    </n-cell-group>
    <n-topic>Button</n-topic>
    <div class="flex flex-col items-center">
      <button id="button" class="m-0" @click="onClick">Button</button>
      <label for="button" class="mt-1.5">Label Area</label>
    </div>
    <n-topic>Input</n-topic>
    <div class="flex flex-col items-center pb-40">
      <input id="input" class="bg-white w-full h-11" placeholder="input..." />
      <label for="input" class="mt-1.5">Label Area</label>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const fruits = reactive([
  { name: "苹果", value: "apple" },
  { name: "香蕉", value: "banana" },
  { name: "菠萝", value: "pineapple", checked: true }
])

const checked1 = ref("菠萝")

const onChangeCheckbox = e => {
  const value = e.detail.value
  let res: string[] = []
  value.forEach(x => {
    const fruit = fruits.find(y => y.value === x)
    if (fruit) {
      res.push(fruit.name)
    }
  })
  checked1.value = res.join(" ")
}

const checked2 = ref("菠萝")

const onChangeRadio = e => {
  const value = e.detail.value
  checked2.value = fruits.find(item => item.value === value)!.name
}

const onClick = () => {
  nz.showToast({ title: "Click" })
}
</script>
