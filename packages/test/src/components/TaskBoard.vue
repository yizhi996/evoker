<template>
  <div class="task">
    <span class="title">{{ task.name }}</span>
    <div class="test" v-for="test of task.tests" :key="test.id">
      <div class="test-info">
        <span>
          <state-icon :state="test.state"></state-icon>
          {{ test.name }}
        </span>
        <span v-if="test.endAt">{{ test.endAt - test.startAt }} ms</span>
      </div>
      <div v-if="test.error" class="test-error">
        {{ test.error }}
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { Task } from "../test"
import StateIcon from "./StateIcon.vue"

defineProps<{ task: Task }>()
</script>

<style scoped>
.task {
  padding: 20px;
  display: flex;
  flex-direction: column;
}

.title {
  font-size: 18px;
  font-weight: bold;
  margin-bottom: 10px;
}

.test {
  margin-left: 15px;
  margin-bottom: 5px;
}

.test-info {
  display: flex;
  justify-content: space-between;
}

.test-error {
  margin-left: 25px;
  word-break: break-all;
  color: orange;
}
</style>
