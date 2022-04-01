<template>
  <n-cell-group class="m-2.5">
    <n-cell title="图片来源">
      <picker
        class="w-full"
        :range="sourceType.range"
        :value="sourceType.value"
        @change="onChangeSourceType"
      >{{ sourceType.range[sourceType.value] }}</picker>
    </n-cell>
    <n-cell title="图片质量">
      <picker
        class="w-full"
        :range="sizeType.range"
        :value="sizeType.value"
        @change="onChangeSizeType"
      >{{ sizeType.range[sizeType.value] }}</picker>
    </n-cell>
    <n-cell title="数量限制">
      <picker
        class="w-full"
        :range="limit.range"
        :value="limit.value"
        @change="onChangeLimit"
      >{{ limit.range[limit.value] }}</picker>
    </n-cell>
  </n-cell-group>
  <button type="primary" @click="onChoose">选择</button>
  <div v-if="images.length" class="m-2.5 bg-white rounded-md shadow-sm p-2">
    <img
      v-for="(src, i) of images"
      :key="src"
      class="w-24 h-24 mr-2 mb-2"
      :src="src"
      mode="aspectFill"
      @click="onPreview(i)"
    />
  </div>
</template>

<script setup lang="ts">
import { ref, reactive } from "vue"

const images = ref<string[]>([])

const sourceType = reactive({
  range: ["拍照", "相册", "拍照或相册"],
  value: 2
})

const onChangeSourceType = ({ value }) => {
  sourceType.value = value
}

const sizeType = reactive({
  range: ["压缩", "原图", "压缩或原图"],
  value: 2
})

const onChangeSizeType = ({ value }) => {
  sizeType.value = value
}

const limit = reactive({
  range: ["1", "2", "3", "4", "5", "6", "7", "8", "9"],
  value: 8
})

const onChangeLimit = ({ value }) => {
  limit.value = value
}

const onChoose = async () => {
  const res = await nz.chooseImage({
    count: parseInt(limit.range[limit.value]),
    sizeType: [["compressed"], ["original"], ["original", "compressed"]][sizeType.value],
    sourceType: [["camera"], ["album"], ["camera", "album"]][sourceType.value],
  })
  images.value = res.tempFilePaths
}

const onPreview = (idx: number) => {
  nz.previewImage({ urls: images.value, current: idx })
}

</script>