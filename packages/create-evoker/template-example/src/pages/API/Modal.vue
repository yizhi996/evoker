<template>
  <div class="w-full flex flex-col items-center justify-center mt-5">
    <button type="primary" @click="onShowModal">有标题的 modal</button>
    <button type="primary" @click="onShowNoTitleModal">无标题的 modal</button>
  </div>
</template>

<script setup lang="ts">
const onShowModal = () => {
  ev.showModal({
    title: "弹窗标题",
    content: "弹窗内容，告知当前状态、信息和解决方法，描述文字尽量控制在三行内",
    showCancel: false
  })
}

const onShowNoTitleModal = () => {
  ev.showModal({
    content: "弹窗内容，告知当前状态、信息和解决方法，描述文字尽量控制在三行内",
    showCancel: false
  })
}
</script>
