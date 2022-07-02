<template>
  <div class="flex flex-col items-center justify-center w-full h-full">
    <button class="mt-5" @click="onShow">弹出 action sheet</button>
  </div>
</template>

<script setup lang="ts">
const onShow = async () => {
  const items = ["item 1", "item 2", "item 3", "item 4"]
  try {
    const result = await ev.showActionSheet({ itemList: items })
    ev.showToast({
      title: `选择了 ${items[result.tapIndex]}`,
      icon: "none"
    })
  } catch {
    ev.showToast({
      title: "cancel",
      icon: "none"
    })
  }
}
</script>
