<template>
  <div class="flex flex-col mx-2.5 mt-5">
    <div class="flex items-center mb-5" v-for="icon of icons" :key="icon.type">
      <icon :type="icon.type" :size="93" :color="icon.color"></icon>
      <div class="flex flex-col ml-2.5">
        <div class="text-lg">{{ icon.name }}</div>
        <span class="text-sm text-gray-500">{{ icon.desc }}</span>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
const icons = [
  {
    type: "success",
    name: "成功",
    desc: "用于表示操作顺利完成"
  },
  {
    type: "info",
    name: "提示",
    desc: "用于表示信息提示；也常用于缺乏条件的操作拦截，提示用户所需信息"
  },
  {
    type: "warn",
    name: "普通警告",
    desc: "用于表示操作后将引起一定后果的情况；也用于表示由于系统原因而造成的负向结果",
    color: "#C9C9C9"
  },
  {
    type: "warn",
    name: "强烈警告",
    desc: "用于表示由于用户原因造成的负向结果；也用于表示操作后将引起不可挽回的严重后果的情况"
  },
  {
    type: "waiting",
    name: "等待",
    desc: "用于表示等待，告知用户结果需等待"
  },
  {
    type: "success-no-circle",
    name: "多选控件图标_已选择",
    desc: "用于多选控件中，表示已选择该项目"
  },
  {
    type: "circle",
    name: "多选控件图标_未选择",
    desc: "用于多选控件中，表示该项目可被选择，但还未选择"
  },
  {
    type: "download",
    name: "下载",
    desc: "用于表示可下载"
  },
  {
    type: "info-circle",
    name: "提示",
    desc: "用于在表单中表示有信息提示"
  },
  {
    type: "cancel",
    name: "停止或关闭",
    desc: "用于在表单中，表示关闭或停止"
  },
  {
    type: "search",
    name: "搜索",
    desc: "用于搜索控件中，表示可搜索"
  }
]
</script>
