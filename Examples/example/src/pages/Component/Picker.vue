<template>
  <n-cell-group class="mt-5 mx-2.5">
    <n-cell title="单列">
      <picker
        class="w-full h-10 bg-white flex items-center"
        header-text="水果"
        :range="fruits.range"
        :value="fruits.value"
        @change="onChangeFruits"
      >
        <div class="px-2.5">当前选择： {{ fruits.range[fruits.value] }}</div>
      </picker>
    </n-cell>
    <n-cell title="多列">
      <picker
        class="w-full h-10 bg-white flex items-center"
        mode="multiSelector"
        :range="weeks.range"
        :value="weeks.value"
        @change="onChangeWeeks"
      >
        <div
          class="px-2.5"
        >当前选择： {{ weeks.range[0][weeks.value[0]] }} {{ weeks.range[1][weeks.value[1]] }}</div>
      </picker>
    </n-cell>
    <n-cell title="联动">
      <picker
        class="w-full h-10 bg-white flex items-center"
        mode="multiSelector"
        :range="cities.range"
        :value="cities.value"
        @change="onChangeCities"
        @columnchange="onColumnChange"
      >
        <div
          class="px-2.5"
        >当前选择： {{ cities.range[0][cities.value[0]] }} {{ cities.range[1][cities.value[1]] }} {{ cities.range[2][cities.value[2]] }}</div>
      </picker>
    </n-cell>
    <n-cell title="时间">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :value="timeValue"
        mode="time"
        start="9:00"
        end="18:00"
        @change="onChangeTime"
      >
        <div class="px-2.5">当前选择： {{ timeValue }}</div>
      </picker>
    </n-cell>
    <n-cell title="日期">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :value="dateValue"
        mode="date"
        start="2014-09-11"
        end="2022-01-01"
        @change="onChangeDate"
      >
        <div class="px-2.5">当前选择： {{ dateValue }}</div>
      </picker>
    </n-cell>
  </n-cell-group>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const fruits = reactive({
  range: ["苹果", "香蕉", "草莓", "菠萝", "西瓜", "桃子", "橙子"],
  value: 0
})

const onChangeFruits = ({ value }) => {
  fruits.value = value
}

const weeks = reactive({
  range: [
    ['周一', '周二', '周三', '周四', '周五'],
    ['上午', '下午', '晚上']
  ],
  value: [0, 0],
  column: 0
})

const onChangeWeeks = ({ value }) => {
  weeks.value = value
}

const cities = reactive({
  range: [["浙江", "福建"], ["杭州", "温州"], ["西湖区", "余杭区"]],
  value: [0, 0, 0]
})

const onChangeCities = ({ value }) => {
  cities.value = value
}

const onColumnChange = ({ column, value }) => {
  cities.value[column] = value
  if (column === 0) {
    if (cities.value[0] === 0) {
      cities.range[1] = ["杭州", "温州"]
      cities.range[2] = ["西湖区", "余杭区"]
    } else if (cities.value[column] === 1) {
      cities.range[1] = ["福州", "厦门"]
      cities.range[2] = ["鼓楼区", "台江区"]
    }
    cities.value[1] = 0
    cities.value[2] = 0
  } else if (column === 1) {
    if (cities.value[0] === 0) {
      if (cities.value[1] === 0) {
        cities.range[2] = ["西湖区", "余杭区"]
      } else if (cities.value[1] === 1) {
        cities.range[2] = ["鹿城区", "瓯海区"]
      }
    } else if (cities.value[0] === 1) {
      if (cities.value[1] === 0) {
        cities.range[2] = ["鼓楼区", "台江区"]
      } else if (cities.value[1] === 1) {
        cities.range[2] = ["思明区", "海沧区"]
      }
    }
    cities.value[2] = 0
  }
}

const timeValue = ref("11:00")

const onChangeTime = ({ value }) => {
  timeValue.value = value
}

const dateValue = ref("2018-08-08")

const onChangeDate = ({ value }) => {
  dateValue.value = value
}

</script>
