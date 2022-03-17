<template>
  <span>选择：{{ selectedDate }}</span>
  <picker-view class="w-full h-80" indicator-class="h-10" :value="value" @change="onChange">
    <picker-view-column>
      <div v-for="item of years" :key="item" class="text-center leading-10">{{ item }}年</div>
    </picker-view-column>
    <picker-view-column>
      <div v-for="item of months" :key="item" class="text-center leading-10">{{ item }}月</div>
    </picker-view-column>
    <picker-view-column>
      <div v-for="item of days" :key="item" class="text-center leading-10">{{ item }}日</div>
    </picker-view-column>
    <picker-view-column>
      <div class="h-10 flex items-center justify-center">
        <image class="w-6 h-6" src="../../assets/kind/daytime.png" />
      </div>
      <div class="h-10 flex items-center justify-center">
        <image class="w-6 h-6" src="../../assets/kind/night.png" />
      </div>
    </picker-view-column>
  </picker-view>
</template>

<script setup lang="ts">
import { ref } from "vue"

const range = (start: number, end: number) => {
  let res = []
  for (let i = start; i <= end; i++) {
    res.push(i)
  }
  return res
}

const years = range(1990, new Date().getFullYear())

const months = range(1, 12)

const days = range(1, 31)

const value = ref<number[]>([9999, 1, 1])

const selectedDate = ref("")

const onChange = ({ value: val }) => {
  value.value = val
  selectedDate.value = `${years[val[0]]}年${months[val[1]]}月${days[val[2]]}日${val[3] ? '黑夜' : '白天'}`
}
</script>