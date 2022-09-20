<template>
  <div class="py-3">
    <TableViewSeciton title="App info">
      <TableViewCell label="URL"> <input v-model:value="app.url" /></TableViewCell>
      <TableViewCell label="AppId">
        <span class="text-gray-500">{{ app.appId }}</span>
      </TableViewCell>
      <TableViewCell label="Env">
        <span class="text-gray-500">{{ app.envVersion }}</span>
      </TableViewCell>
      <TableViewCell label="Version">
        <span class="text-gray-500">{{ app.version || "unknown" }}</span>
      </TableViewCell>
      <TableViewCell label="Name">
        <span class="text-gray-500">{{ app.name }}</span>
      </TableViewCell>
      <TableViewCell label="Desc">
        <span class="text-gray-500">{{ app.desc }}</span>
      </TableViewCell>
    </TableViewSeciton>
    <div v-if="app.appId" class="mx-5">
      <button type="primary" size="large" @click="save">Save</button>
    </div>
    <div class="text-lg mt-14 text-center" style="color: #ff3b30">
      <span @click="del">Delete</span>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue"
import { usePage } from "evoker"
import { useLocalStore, App, EnvVersion } from "../storage"
import TableViewCell from "../components/TableViewCell.vue"
import TableViewSeciton from "../components/TableViewSeciton.vue"
import { deleteApp, disconnectDevServer } from "../bridge"
import { isEqualApp, isWebSocketURL } from "../utils"

const storage = useLocalStore()

const { onLoad } = usePage()

const app = ref<App>(null)

onLoad(query => {
  const appId = query.appId as string
  const envVersion = query.envVersion as EnvVersion
  const finding = { appId, envVersion }
  const _app = storage.apps.find(a => isEqualApp(a, finding))
  if (_app) {
    app.value = JSON.parse(JSON.stringify(_app))
    ek.setNavigationBarTitle({ title: _app.name || _app.appId })
  } else {
    ek.setNavigationBarTitle({ title: appId })
  }
})

const save = () => {
  const i = storage.apps.findIndex(a => isEqualApp(a, app.value))
  if (i > -1) {
    const prev = storage.apps[i]
    if (prev.url !== app.value.url && isWebSocketURL(app.value.url)) {
      disconnectDevServer({ url: app.value.url })
    }
    storage.apps[i] = app.value
    storage.saveLocalApps()
  }
  ek.navigateBack()
}

const del = async () => {
  const res = await ek.showModal({
    title: `Delete "${app.value.name || app.value.appId}"?`,
    content: "Deleting this app will also delete its data.",
    confirmText: "Delete",
    confirmColor: "#ff3b30",
    cancelText: "Cancel",
    cancelColor: "#007aff"
  })
  if (res.confirm) {
    const instance = app.value
    const i = storage.apps.findIndex(a => isEqualApp(a, instance))
    if (i > -1) {
      if (isWebSocketURL(instance.url)) {
        disconnectDevServer({ url: instance.url })
      }
      deleteApp({ appId: instance.appId, envVersion: instance.envVersion })
      storage.apps.splice(i, 1)
      storage.saveLocalApps()
      ek.navigateBack()
    }
  }
}
</script>
