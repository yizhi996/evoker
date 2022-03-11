<template>
    <div class="mx-3 mt-3">auto focus input, isFocus: {{ focus }}, keyboard height: {{ kbHeight }}</div>
    <div class="p-4 bg-white">
        <input
            v-model="value"
            placeholder="请输入"
            focus
            @focus="onFocus"
            @blur="onBlur"
            @confirm="onConfirm"
            @keyboard-height-change="onKeybardHeightChange"
        />
    </div>
    <div class="mx-3 mt-3">max length is 10 input</div>
    <div class="p-4 bg-white">
        <input v-model="value1" placeholder="请输入" :maxlength="10" />
    </div>
    <div class="mx-3 mt-3">input value: {{ inputText }}</div>
    <div class="p-4 bg-white">
        <input v-model="inputText" placeholder="请输入" />
    </div>
    <div class="mx-3 mt-3">password: {{ password }}</div>
    <div class="p-4 bg-white">
        <input v-model="password" password placeholder="请输入" />
    </div>
    <div class="mx-3 mt-3">number input</div>
    <div class="p-4 bg-white">
        <input type="number" placeholder="请输入" :model-value="inputText" />
    </div>
    <div class="mx-3 mt-3">decimal input</div>
    <div class="p-4 bg-white">
        <input type="digit" placeholder="请输入" :model-value="inputText" />
    </div>
</template>

<script setup lang="ts">
import { ref } from "vue"

const focus = ref(false)
const value = ref("")
const value1 = ref("默认值")
const inputText = ref("")
const password = ref("")
const kbHeight = ref(0)

const onFocus = () => {
    focus.value = true
}

const onBlur = () => {
    focus.value = false
}

const onConfirm = (value: string) => {
    console.log(value)
}

const onKeybardHeightChange = (data: { height: number }) => {
    kbHeight.value = data.height
}
</script>
