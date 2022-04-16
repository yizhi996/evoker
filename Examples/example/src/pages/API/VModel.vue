<template>
  <div class="flex flex-col w-full items-center justify-center mt-5">
    <div>Page Component</div>
    <v-model-test class="mt-5" v-model="text"></v-model-test>
    <div class="mt-5 bg-green-500 p-5">
      <div class="text-white">BuiltIn Component</div>
      <slider v-model:value="sliderValue"></slider>
    </div>
    <button class="mt-5" @click="onChange">Outer Change</button>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import VModelTest from "../../components/VModelTest.vue"

const text = ref("")
const sliderValue = ref(50)

const onChange = () => {
  text.value = "OUTER"
  sliderValue.value = 80
}

</script> 