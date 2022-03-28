<template>
  <div class="w-full bg-white p-2">
    <template v-if="Object.keys(object).length">
      <template v-for="(value, name) of object" :key="name">
        <div class="text-blue-400">
          {{ name }}:
          <span class="text-orange-400 ml-1">{{ value }}</span>
        </div>
      </template>
    </template>
    <div v-else class="flex items-center justify-center text-gray-400 py-8">{{ placeholder }}</div>
  </div>
</template>

<script setup lang="ts">
defineProps<{ object: Record<string, any>, placeholder?: string }>()
</script>