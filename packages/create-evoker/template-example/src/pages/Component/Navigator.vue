<template>
  <navigator url="./Text">
    <button>打开页面</button>
  </navigator>
  <navigator open-type="navigateBack">
    <button>返回</button>
  </navigator>
  <navigator open-type="redirect" url="./Text">
    <button>重定向</button>
  </navigator>
</template>

<script setup lang="ts"></script>
