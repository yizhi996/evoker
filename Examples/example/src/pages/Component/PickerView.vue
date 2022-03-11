<template>
    <picker-view class="w-full h-48" title="标题" :columns="columns"></picker-view>
</template>

<script setup lang="ts">
import { ref } from "vue"

const columns = ['苹果', '香蕉', '菠萝', '橘子', '草莓', '柠檬', '西瓜']

</script>