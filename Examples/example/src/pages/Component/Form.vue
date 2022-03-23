<template>
  <div class="mt-5 mx-2.5">
    <form @submit="onSubmit" @reset="onReset">
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
          <slider class="w-full" :value="50" name="volume" />
        </cell>
        <cell title="多选">
          <checkbox-group name="fruits">
            <checkbox class="mb-1.5" value="pineapple">菠萝</checkbox>
            <checkbox value="bababa">香蕉</checkbox>
          </checkbox-group>
        </cell>
        <cell title="单选">
          <radio-group name="radio">
            <radio value="1">单选1</radio>
            <radio value="2">单选2</radio>
          </radio-group>
        </cell>
        <cell title="Picker">
          <picker
            class="w-full"
            header-title="📱品牌"
            name="picker"
            :range="columns"
            :value="info.pickerIndex"
            @change="onChangePicker"
          >
            <div class="w-full">当前选择： {{ columns[info.pickerIndex] }}</div>
          </picker>
        </cell>
      </cell-group>
      <button class="w-full" type="primary" form-type="submit">Submit</button>
      <button class="w-full" form-type="reset">Reset</button>
    </form>

    <div>{{ form }}</div>
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"
import CellGroup from "../../components/CellGroup.vue"
import Cell from "../../components/Cell.vue"

const info = reactive({ username: "", password: "", pickerIndex: 0 })

const form = ref({})

const columns = ["Apple", "OPPO", "vivo", "Xiaomi", "Others"]

const onSubmit = ({ value }) => {
  form.value = value
}

const onReset = () => {
  form.value = {}
}

const onChangePicker = ({ value }) => {
  info.pickerIndex = value
}
</script>
