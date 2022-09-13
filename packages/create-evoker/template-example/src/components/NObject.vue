<template>
  <div class="w-full bg-white p-2">
    <template v-if="Object.keys(object).length">
      <template v-for="item of sorted" :key="item.key">
        <div class="text-blue-400">
          {{ item.key }}:
          <span class="text-orange-400 ml-1 break-all">{{ item.value }}</span>
        </div>
      </template>
    </template>
    <div v-else class="flex items-center justify-center text-gray-400 py-8">{{ placeholder }}</div>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue"
import { isString } from "@vue/shared"

const props = defineProps<{ object: Record<string, any>; placeholder?: string }>()

const sorted = computed(() => {
  const obj = props.object
  if (isString(obj)) {
    return [{ key: "body", value: obj }]
  }

  const res = []
  for (const key in obj) {
    res.push({ key, value: obj[key] })
  }

  res.sort(function (a, b) {
    return a.key < b.key ? -1 : 1
  })

  return res
})
</script>
