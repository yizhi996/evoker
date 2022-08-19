<template>
  <div class="tasks">
    <div class="task" v-for="task of tasks" :key="task.id">
      <state-icon :state="task.state"></state-icon>
      {{ task.name }}
      <div class="sub" v-for="(sub, i) of task.tasks" :key="i">
        <div>
          <state-icon :state="sub.state"></state-icon>
          {{ sub.name }}
        </div>
        <span v-if="sub.endAt">{{ sub.endAt - sub.startAt }} ms</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { usePage } from "evoker"
import { tasks, run } from "../test"
import StateIcon from "./StateIcon.vue"
import "../spec/base"
import "../spec/system"
import "../spec/storage"
import "../spec/network"

const { onReady } = usePage()

onReady(() => {
  run()
})
</script>

<style scoped>
.tasks {
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.task {
  margin-bottom: 10px;
}

.sub {
  margin-left: 22px;
  display: flex;
  justify-content: space-between;
}
</style>
