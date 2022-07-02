<template>
  <div class="relative h-56">
    <video
      id="my-video"
      class="w-full h-full"
      show-screen-lock-button
      title="This Title"
      :show-progress="true"
      vslide-gesture
      :show-center-play-btn="false"
      :autoplay="false"
      :muted="true"
      show-mute-btn
      :src="data.videoURL"
      :poster="data.poster"
      loop
    ></video>
  </div>

  <button @click="change">CHANGE</button>

  <n-topic>使用 VideoContext 控制</n-topic>
  <button @click="play">PLAY</button>
  <button @click="pause">PAUSE</button>
  <button @click="stop">STOP</button>
  <button @click="seek">SEEK</button>
  <button @click="setPlaybackRate">2x</button>
  <button @click="enterFullScreen">ENTER FULL SCREEN</button>
</template>

<script setup lang="ts">
import { reactive } from "vue"
import { usePage, VideoContext } from "evoker"

const { onReady } = usePage()

let ctx: VideoContext | null

onReady(() => {
  ev.createSelectorQuery()
    .select("#my-video")
    .context(res => {
      ctx = res.context
      console.log(ctx)
    })
    .exec()
})

const videos = [
  "https://file.lilithvue.com/lilith-test-assets/v0200fg10000c8fdbqbc77ufgqhbio20.mp4",
  "https://file.lilithvue.com/lilith-test-assets/BigBuckBunny.mp4"
]

const data = reactive({
  videoURL: videos[0],
  poster: ""
})

const change = () => {
  if (data.videoURL === videos[0]) {
    data.videoURL = videos[1]
  } else {
    data.videoURL = videos[0]
  }
}

const play = () => {
  ctx?.play()
}

const pause = () => {
  ctx?.pause()
}

const stop = () => {
  ctx?.pause()
}

const seek = () => {
  ctx?.seek(10)
}

const setPlaybackRate = () => {
  ctx?.playbackRate(2)
}

const enterFullScreen = () => {
  ctx?.requestFullScreen()
}
</script>
