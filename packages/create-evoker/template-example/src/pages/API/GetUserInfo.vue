<template>
  <div class="m-2.5 text-sm text-gray-500">
    getUserProfile 和 getUserInfo 接口需要根据自生业务在 native 端自行实现。具体请查看 EngineConfig.hooks
    的 openAPI。
  </div>
  <div class="flex flex-col items-center justify-center">
    <img class="w-24 h-24 rounded-full" :src="userInfo.avatar" />
    <span class="text-lg font-semibold">{{ userInfo.nickname }}</span>
  </div>
  <n-topic>getUserProfile</n-topic>
  <button type="primary" @click="getUserProfile">获取用户信息</button>

  <n-topic>getUserInfo</n-topic>
  <button type="primary" open-type="getUserInfo" @getuserinfo="getUserInfo">获取用户信息</button>
</template>

<script setup lang="ts">
import { reactive } from "vue"

let userInfo = reactive({ nickname: "", avatar: "" })

const getUserProfile = async () => {
  const res = await ek.getUserProfile({
    desc: "用于完善会员资料"
  })
  userInfo.nickname = res.userInfo.nickName
  userInfo.avatar = res.userInfo.avatarUrl
}

const getUserInfo = e => {
  const { userInfo: res } = e.detail
  if (res) {
    userInfo.nickname = res.nickName
    userInfo.avatar = res.avatarUrl
  }
}
</script>
