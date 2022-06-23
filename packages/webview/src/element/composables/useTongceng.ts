import { ref, onMounted, onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { getRandomInt } from "../utils"

let incTongcengId = 1000

const enum NativeInvokeKeys {
  INSERT = "insertContainer",
  UPDATE = "updateContainer",
  REMOVE = "removeContainer"
}

export function useTongceng(options: { scrollEnabled?: boolean } = { scrollEnabled: false }) {
  const tongcengId = incTongcengId++
  const tongcengKey = "__nzoth_tongceng_id_" + tongcengId
  const tongcengRef = ref<HTMLElement>()
  const tongcengHeight = `${418094 + tongcengId}px`

  let retryLimit = 5
  let containerInserting = false
  let containerInserted = false

  onMounted(() => {
    tongcengRef.value && tongcengRef.value.addEventListener("resize", onResize)
  })

  onUnmounted(() => {
    tongcengRef.value && tongcengRef.value.removeEventListener("resize", onResize)
    removeContainer()
  })

  const onResize = () => {
    updateContainer()
  }

  const nextTick = (fn: () => void) => {
    requestAnimationFrame(() => {
      let invoked = false
      const run = () => {
        if (!invoked) {
          fn()
          invoked = true
        }
      }
      setTimeout(run, 10)
      requestAnimationFrame(run)
    })
  }

  const getContainerBox = () => {
    if (tongcengRef.value) {
      const rect = tongcengRef.value.getBoundingClientRect()
      return {
        left: rect.left + window.scrollX,
        top: rect.top + window.scrollY,
        width: Math.round(rect.width),
        height: Math.round(rect.height),
        scrollHeight: tongcengRef.value.scrollHeight
      }
    }
    return {
      left: 0,
      top: 0,
      width: 0,
      height: 0,
      scrollHeight: 0
    }
  }

  const insertContainer = async (callback: (success: boolean) => void) => {
    if (retryLimit <= 0) {
      callback(false)
      return
    }
    const position = getContainerBox()
    nextTick(() => {
      if (containerInserting || containerInserted) {
        return
      }
      containerInserting = true
      NZJSBridge.invoke(
        NativeInvokeKeys.INSERT,
        {
          tongcengId: tongcengKey,
          position,
          scrollEnabled: options.scrollEnabled
        },
        result => {
          if (result.errMsg) {
            containerInserting = false
            containerInserted = false
            if (position.width !== 0 && position.height !== 0) {
              retryLimit--
              console.warn(`insert native container retry times ${retryLimit}`)
              insertContainer(callback)
            } else {
              callback(false)
            }
          } else {
            containerInserting = false
            containerInserted = true
            callback(true)
          }
        }
      )
    })
  }

  let onUpdatedContainerCallback: () => void

  const updateContainer = () => {
    if (containerInserted) {
      const position = getContainerBox()
      nextTick(() => {
        NZJSBridge.invoke(
          NativeInvokeKeys.UPDATE,
          {
            tongcengId: tongcengKey,
            position
          },
          () => {
            onUpdatedContainerCallback && onUpdatedContainerCallback()
          }
        )
      })
    }
  }

  const removeContainer = () => {
    if (containerInserted) {
      NZJSBridge.invoke(NativeInvokeKeys.REMOVE, {
        tongcengId: tongcengKey
      })
    }
  }

  const onUpdatedContainer = (callback: () => void) => {
    onUpdatedContainerCallback = callback
  }

  return {
    tongcengId,
    tongcengKey,
    nativeId: getRandomInt(10000, 10000000),
    tongcengRef: tongcengRef,
    tongcengHeight,
    getContainerBox,
    insertContainer,
    updateContainer,
    removeContainer,
    onUpdatedContainer
  }
}
