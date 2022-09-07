<template>
  <div v-for="task of tasks">
    <navigator :url="task">
      <button>{{ task }}</button>
    </navigator>
  </div>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { ref } from "vue"

const { onShareAppMessage } = usePage()

onShareAppMessage(() => {
  return {
    title: "Share",
    path: "components/Main"
  }
})

const tasks = ref(["Base", "System", "Interaction", "Storage", "Network", "WebSocket"])
</script>
