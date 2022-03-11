import { ref, onMounted, onUnmounted } from "vue"
import { NZJSBridge } from "../../bridge"
import { getRandomInt } from "../utils"

let incTongcengId = 1000

const enum NativeInvokeKeys {
  INSERT = "insertContainer",
  UPDATE = "updateContainer",
  REMOVE = "removeContainer"
}

export default function useNative() {
  const tongcengId = incTongcengId++
  const tongcengKey = "__nzoth_tongceng_id_" + tongcengId
  const containerRef = ref<HTMLElement>()
  const innerRef = ref<HTMLElement>()
  const height = "height:" + `${418094 + tongcengId}px`

  let retryLimit = 5
  let containerInserting = false
  let containerInserted = false

  onMounted(() => {
    containerRef.value &&
      containerRef.value.addEventListener("resize", onResize)
  })

  onUnmounted(() => {
    containerRef.value &&
      containerRef.value.removeEventListener("resize", onResize)
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
    if (containerRef.value) {
      const rect = containerRef.value.getBoundingClientRect()
      return {
        left: rect.left + window.scrollX,
        top: rect.top + window.scrollY,
        width: rect.width,
        height: rect.height,
        scrollHeight: containerRef.value.scrollHeight
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
        { tongcengId: tongcengKey, position },
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

  const updateContainer = () => {
    if (containerInserted) {
      const position = getContainerBox()
      nextTick(() => {
        NZJSBridge.invoke(NativeInvokeKeys.UPDATE, {
          tongcengId: tongcengKey,
          position
        })
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

  return {
    tongcengId,
    tongcengKey,
    nativeId: getRandomInt(10000, 10000000),
    containerRef,
    innerRef,
    height,
    getContainerBox,
    insertContainer,
    updateContainer,
    removeContainer
  }
}
