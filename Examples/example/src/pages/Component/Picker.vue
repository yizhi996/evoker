<template>
  <cell-group class="mt-5 mx-2.5">
    <cell title="单列">
      <picker
        class="w-full h-10 bg-white flex items-center"
        title="食物"
        :columns="columns"
        :default-index="defaultIndex"
        @confirm="onConfirm"
        @cancel="onCancel"
      >
        <div class="px-2.5">当前选择： {{ current }}</div>
      </picker>
    </cell>
    <cell title="多列">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :columns="columns1"
        @confirm="onConfirm1"
        @cancel="onCancel"
      >
        <div class="px-2.5">当前选择： {{ current1 }}</div>
      </picker>
    </cell>
    <cell title="联动">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :columns="columns2"
        :default-index="defaultIndex"
        @confirm="onConfirm2"
        @cancel="onCancel"
      >
        <div class="px-2.5">当前选择： {{ current2 }}</div>
      </picker>
    </cell>
    <cell title="时间">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :value="timeValue"
        title="时间"
        mode="time"
        start="9:00"
        end="18:00"
        @confirm="onTimeConfirm"
        @cancel="onCancel"
      >
        <div class="px-2.5">当前选择： {{ timeValue }}</div>
      </picker>
    </cell>
    <cell title="日期">
      <picker
        class="w-full h-10 bg-white flex items-center"
        :value="dateValue"
        title="日期"
        mode="date"
        start="2014-09-11"
        end="2022-01-01"
        @confirm="onDateConfirm"
        @cancel="onCancel"
      >
        <div class="px-2.5">当前选择： {{ dateValue }}</div>
      </picker>
    </cell>
  </cell-group>
</template>

<script setup lang="ts">
import { ref } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const columns = ref(["苹果", "香蕉", "草莓", "菠萝", "西瓜", "桃子", "橙子"])

const columns1 = ref([
  {
    values: ['周一', '周二', '周三', '周四', '周五'],
    defaultIndex: 2,
  },
  {
    values: ['上午', '下午', '晚上'],
    defaultIndex: 1,
  },
])

const columns2 = ref([
  {
    text: "浙江",
    children: [
      {
        text: "杭州",
        children: [{ text: "西湖区" }, { text: "余杭区" }]
      },
      {
        text: "温州",
        children: [{ text: "鹿城区" }, { text: "瓯海区" }]
      }
    ]
  },
  {
    text: "福建",
    children: [
      {
        text: "福州",
        children: [{ text: "鼓楼区" }, { text: "台江区" }]
      },
      {
        text: "厦门",
        children: [{ text: "思明区" }, { text: "海沧区" }]
      }
    ]
  }
])

const current = ref("草莓")
const current1 = ref("")
const current2 = ref("")
const timeValue = ref("11:00")
const dateValue = ref("2018-08-08")
const defaultIndex = ref(2)

const onConfirm = (value: string, index: number) => {
  nz.showToast({
    title: `当前值: ${value}, 当前索引: ${index}`
  })
  current.value = value
  defaultIndex.value = index
}

const onConfirm1 = (values: string[], indexs: number[]) => {
  current1.value = values.join(" ")
  let i = 0
  indexs.forEach(idx => {
    columns1.value[i].defaultIndex = idx
    i += 1
  })
}

const onConfirm2 = (values: string[], indexs: number[]) => {
  current2.value = values.join(" ")
}

const onTimeConfirm = (value: string) => {
  timeValue.value = value
}

const onDateConfirm = (value: string) => {
  dateValue.value = value
}

const onCancel = () => nz.showToast({ title: "取消", icon: "none" })
</script>
