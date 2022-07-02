<script setup lang="ts">
import { useApp } from "evoker"

const { onLaunch, onShow, onHide, onError, onThemeChange } = useApp()

onLaunch(options => {
  console.log("APP onLaunch: ", options)
})

onShow(options => {
  console.log("APP onShow: ", options)
})

onHide(() => {
  console.log("APP onHide")
})

onError(error => {
  console.log("APP Error: ", error)
})

onThemeChange(options => {
  console.log("theme change: ", options.theme)
})
</script>

<style>
body {
  background-color: #f3f4f6;
}

.navigator-arrow {
  padding-right: 13px;
  position: relative;
}

.navigator-arrow:after {
  content: " ";
  display: inline-block;
  height: 9px;
  width: 9px;
  border-width: 1px 1px 0 0;
  border-color: #888888;
  border-style: solid;
  transform: matrix(0.71, 0.71, -0.71, 0.71, 0, 0);
  position: absolute;
  top: 50%;
  margin-top: -4px;
  right: 14px;
}

.square-image {
  position: relative;
}

.square-image::before {
  content: "";
  display: block;
  width: 100%;
  padding-bottom: 100%;
}
</style>
