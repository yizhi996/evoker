<template>
  <div class="mx-2.5 mt-2.5">
    <topic>{{ checked }}</topic>
    <checkbox-group class="mt-2.5" @change="onChange">
      <cell-group>
        <cell v-for="fruit of fruits" :key="fruit.value">
          <checkbox
            class="w-full h-full"
            :value="fruit.value"
            :checked="fruit.checked"
          >{{ fruit.name }}</checkbox>
        </cell>
      </cell-group>
    </checkbox-group>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const fruits = reactive([
  { name: "苹果", value: "apple" },
  { name: "香蕉", value: "banana" },
  { name: "菠萝", value: "pineapple", checked: true },
  { name: "葡萄", value: "grape" },
  { name: "柠檬", value: "lemon" }
])

const checked = ref("菠萝")

const onChange = ({ value }) => {
  let res: string[] = []
  value.forEach(x => {
    const fruit = fruits.find(y => y.value === x)
    if (fruit) {
      res.push(fruit.name)
    }
  })
  checked.value = res.join(" ")
}
</script>
