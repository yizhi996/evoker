<template>
  <div class="mt-5 mx-2.5">
    <form @submit="onSubmit">
      <cell-group>
        <cell title="用户名">
          <input v-model="info.username" name="account" placeholder="请输入用户名" />
        </cell>
        <cell title="密码">
          <input v-model="info.password" password name="password" placeholder="请输入密码" />
        </cell>
        <cell title="静音">
          <switch name="muted" />
        </cell>
        <cell title="音量">
          <slider class="w-full" :model-value="50" name="volume" />
        </cell>
        <cell title="选项">
          <checkbox name="checkbox">记住密码</checkbox>
        </cell>
        <cell title="多选">
          <checkbox-group name="fruits">
            <checkbox class="mb-1.5" name="pineapple">菠萝</checkbox>
            <checkbox name="bababa">香蕉</checkbox>
          </checkbox-group>
        </cell>
        <cell title="单选">
          <radio-group name="radio">
            <radio name="1">单选1</radio>
            <radio name="2">单选2</radio>
          </radio-group>
        </cell>
        <cell title="Picker">
          <picker
            class="w-full"
            title="📱品牌"
            name="picker"
            :columns="columns"
            :default-index="info.pickerIndex"
            @confirm="onConfirm"
          >
            <div class="w-full">当前选择： {{ info.pickerSelected }}</div>
          </picker>
        </cell>
      </cell-group>
      <button class="w-full" type="primary" form-type="submit">Submit</button>
      <button class="w-full" form-type="reset">Reset</button>
    </form>
  </div>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const info = reactive({ username: "", password: "", pickerSelected: "", pickerIndex: 0 })

const columns = ["Apple", "OPPO", "vivo", "Xiaomi", "Others"]

const onSubmit = (values: Record<string, any>) => {
  nz.showToast({ title: "Submit", icon: "success" })
}

const onConfirm = (value: string, index: number) => {
  info.pickerSelected = value
  info.pickerIndex = index
}
</script>
