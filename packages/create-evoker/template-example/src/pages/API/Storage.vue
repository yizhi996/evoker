<template>
  <n-cell-group class="m-2.5">
    <n-cell title="key">
      <input class="w-full bg-white" v-model:value="key" placeholder="请输入 key" />
    </n-cell>
    <n-cell title="value">
      <input class="w-full bg-white" v-model:value="value" placeholder="请输入 value" />
    </n-cell>
  </n-cell-group>
  <button type="primary" @click="setStorage">存储数据</button>
  <button @click="getStorage">读取数据</button>
  <button @click="clearStorage">清理数据</button>
</template>

<script setup lang="ts">
import { ref } from "vue"

const key = ref("")

const value = ref("")

const setStorage = () => {
  if (key.value.length) {
    ek.setStorage({ key: key.value, data: value.value })
    ek.showModal({
      title: "存储数据成功"
    })
  } else {
    ek.showModal({
      title: "保存数据失败",
      content: "key 不能为空"
    })
  }
}

const getStorage = async () => {
  if (key.value.length) {
    try {
      const res = await ek.getStorage({ key: key.value })
      value.value = res.data
      ek.showModal({
        title: "读取数据成功",
        content: `${res.data}`
      })
    } catch (error) {
      ek.showModal({
        title: "读取数据失败",
        content: error.errMsg
      })
    }
  } else {
    ek.showModal({
      title: "读取数据失败",
      content: "key 不能为空"
    })
  }
}

const clearStorage = () => {
  ek.clearStorage()
}
</script>
