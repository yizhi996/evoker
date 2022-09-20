<template>
  <div class="m-3">
    <span>flex-direction: row 横向布局</span>
    <div class="mt-2.5 flex justify-center">
      <div class="flex">
        <div class="bg-green-500 w-24 h-36 text-white flex items-center justify-center">A</div>
        <div class="bg-blue-500 w-24 h-36 text-white flex items-center justify-center">B</div>
        <div class="bg-gray-200 w-24 h-36 text-black flex items-center justify-center">C</div>
      </div>
    </div>
  </div>
  <div class="m-3">
    <span>flex-direction: row 横向布局</span>
    <div class="mt-2.5 flex justify-center">
      <div class="flex flex-col mt-2.5 mx-2.5">
        <div class="bg-green-500 h-24 w-36 text-white flex items-center justify-center">A</div>
        <div class="bg-blue-500 h-24 w-36 text-white flex items-center justify-center">B</div>
        <div class="bg-gray-200 h-24 w-36 text-black flex items-center justify-center">C</div>
      </div>
    </div>

    <view class="normal" hover-class="hover" :hover-stay-time="100">Hover</view>
  </div>
</template>

<script setup lang="ts"></script>

<style scoped>
.normal {
  width: 100%;
  height: 44px;
  margin-top: 10px;
  border-radius: 6px;
  background-color: orange;
  display: flex;
  align-items: center;
  justify-content: center;
}
.hover {
  background-color: palevioletred;
  color: white;
}
</style>
