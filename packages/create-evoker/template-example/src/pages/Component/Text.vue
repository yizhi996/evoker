<template>
  <div class="m-5 bg-white rounded-sm shadow-sm p-3" style="min-height: 200px">
    <span class="whitespace-pre-line" v-for="text of texts" :key="text">{{ text }}</span>
  </div>
  <button type="primary" @click="add" :disabled="!canAdd">add line</button>
  <button @click="remove" :disabled="!canRemove">remove line</button>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const data = [
  "Vue.js 是什么\n",
  "Vue (读音 /vjuː/，类似于 view) 是一套用于构建用户界面的渐进式框架。\n",
  "与其它大型框架不同的是，Vue 被设计为可以自底向上逐层应用。\n",
  "Vue 的核心库只关注视图层，不仅易于上手，还便于与第三方库或既有项目整合。\n",
  "另一方面，当与现代化的工具链以及各种支持类库结合使用时，Vue 也完全能够为复杂的单页应用提供驱动。\n",
  "......\n"
]

const texts = reactive<string[]>([])
const canAdd = ref(true)
const canRemove = ref(false)

const add = () => {
  const text = data[texts.length]
  texts.push(text)
  canAdd.value = texts.length < data.length
  canRemove.value = texts.length > 0
}

const remove = () => {
  texts.pop()
  canAdd.value = texts.length < data.length
  canRemove.value = texts.length > 0
}
</script>
