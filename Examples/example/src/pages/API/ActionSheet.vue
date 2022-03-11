<template>
  <div class="flex flex-col items-center justify-center w-full h-full">
    <button class="mt-5" @click="onShow">弹出 action sheet</button>
  </div>
</template>

<script setup lang="ts">

const onShow = () => {
  const items = ["item 1", "item 2", "item 3", "item 4"]
  nz.showActionSheet({
    itemList: items
  }).then(tapIndex => {
    if (tapIndex === -1) {
      nz.showToast({
        title: "cancel",
        icon: "none"
      })
    } else {
      nz.showToast({
        title: `选择了 ${items[tapIndex]}`,
        icon: "none"
      })
    }

  })
}
</script>