<template>
  <set-tab-bar v-if="showPopup === 'set-tab-bar'" @close="showPopupComponent('')"></set-tab-bar>
  <template v-else>
    <div class="mx-5 mt-3 text-sm dark:text-white">{{ desc }}</div>
    <div class="flex flex-col mx-5 my-3">
      <div v-for="item of list" :key="item.id" class="flex flex-col bg-white dark:bg-black mb-2.5 rounded-sm relative">
        <div class="flex justify-between items-center w-full h-14"
          :class="item.open ? 'text-gray-300' : 'text-black dark:text-white'" @click="onShowPageList(item)">
          <span class="ml-3">{{ item.name }}</span>
          <img class="mr-3 w-6 h-6" :src="getSrc(item.id)" />
        </div>
        <div class="bg-white dark:bg-black rounded-b-sm relative overflow-hidden" :class="item.open ? 'h-auto' : 'h-0'">
          <div class="flex flex-col duration-300 opacity-0 -translate-y-1/2"
            :class="item.open ? 'translate-y-0 opacity-100' : ''">
            <template v-for="page of item.pages" :key="page.url">
              <div v-if="page.url.startsWith('@')" @click="showPopupComponent(page.url)"
                class="flex items-center justify-between w-full h-10 border-b dark:border-gray-300 last:border-0">
                <span class="mx-2.5 dark:text-white">{{ page.name ? page.name : page.url }}</span>
                <div class="navigator-arrow"></div>
              </div>
              <navigator v-else :url="page.url"
                class="flex items-center justify-between w-full h-10 border-b dark:border-gray-300 last:border-0">
                <span class="mx-2.5 dark:text-white">{{ page.name ? page.name : page.url }}</span>
                <div class="navigator-arrow"></div>
              </navigator>
            </template>
          </div>
        </div>
      </div>
    </div>
  </template>
</template>

<script setup lang="ts">
import { ref } from "vue"
import SetTabBar from "../pages/API/SetTabBar.vue"

interface PageGroup {
  id: string
  name: string
  open: boolean
  pages: PageInfo[]
}

interface PageInfo {
  name?: string
  url: string
}

const props = defineProps<{
  desc: string,
  list: PageGroup[]
}>()

const onShowPageList = (cur: PageGroup) => {
  const others = props.list.filter(item => { return item.id !== cur.id })
  others.forEach(item => { item.open = false })
  cur.open = !cur.open
}

const getSrc = (name: string) => {
  const path = `/src/assets/kind/${name}.png`
  const modules = import.meta.globEager("/src/assets/kind/*.png")
  return modules[path].default
}

const showPopup = ref("")

const showPopupComponent = (is: string) => {
  showPopup.value = is.substring(1)
}

</script>