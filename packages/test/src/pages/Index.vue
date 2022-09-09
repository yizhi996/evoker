<template>
  <div class="grid">
    <navigator
      v-for="task of tasks"
      class="grid-item"
      :class="{ 'grid-item-empty': !task }"
      :url="task"
    >
      {{ task }}
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

const tasks = ref([
  "Base",
  "System",
  "Interaction",
  "Navigation",
  "Storage",
  "Network",
  "WebSocket"
])

if (tasks.value.length % 2) {
  tasks.value.push("")
}
</script>

<style scoped>
.grid {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  justify-content: center;
}

.grid-item {
  width: 40%;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  margin-bottom: 20px;
  border: 1px solid gray;
}

.grid-item-empty {
  border: none;
}

.content {
  width: 100%;
  height: 100%;
}

.grid-item:nth-child(odd) {
  margin-right: 10px;
}
</style>
