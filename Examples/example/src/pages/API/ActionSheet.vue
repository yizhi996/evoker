<template>
  <div class="flex flex-col items-center justify-center w-full h-full">
    <button class="mt-5" @click="onShow">弹出 action sheet</button>
  </div>
</template>

<script setup lang="ts">
const onShow = async () => {
  const items = ["item 1", "item 2", "item 3", "item 4"]
  const result = await nz.showActionSheet({ itemList: items })
  if (result.tapIndex == -1) {
    nz.showToast({
      title: "cancel",
      icon: "none"
    })
  } else {
    nz.showToast({
      title: `选择了 ${items[result.tapIndex]}`,
      icon: "none"
    })
  }
}
</script>
