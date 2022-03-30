<template>
  <cell-group class="m-2.5">
    <cell title="copy">
      <input class="w-full bg-white" v-model:value="copy" />
    </cell>
    <cell title="paste">
      <input class="w-full bg-white" v-model:value="paste" />
    </cell>
  </cell-group>
  <button type="primary" @click="onSet">复制</button>
  <button @click="onGet">粘贴</button>
</template>

<script setup lang="ts">
import { ref } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const copy = ref("123")

const paste = ref("")

const onGet = async () => {
  const res = await nz.getClipboardData()
  paste.value = res.data
}

const onSet = () => {
  nz.setClipboardData({ data: copy.value })
}
</script>