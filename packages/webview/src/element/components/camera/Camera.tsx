import { defineComponent, onMounted, PropType, watch } from "vue"
import { JSBridge, showModal } from "../../../bridge"
import { useTongceng } from "../../composables/useTongceng"
import { useCamera } from "../../composables/useCamera"
import { AuthorizationStatus } from "../../utils"

const props = {
  mode: { type: String as PropType<"normal" | "scanCode">, default: "normal" },
  resolution: { type: String as PropType<"low" | "medium" | "high">, default: "medium" },
  devicePosition: { type: String as PropType<"front" | "back">, default: "back" },
  flash: { type: String as PropType<"auto" | "on" | "off" | "torch">, default: "auto" }
}

export default defineComponent({
  name: "ek-camera",
  props,
  emits: ["initdone", "scancode", "error", "stop"],
  setup(props, { emit }) {
    const {
      tongcengKey,
      nativeId: cameraId,
      tongcengRef,
      tongcengHeight,
      insertContainer
    } = useTongceng()

    const { onInit, onScanCode, onError, authorize } = useCamera(cameraId)

    onInit(data => {
      emit("initdone", { maxZoom: data.maxZoom })
    })

    onScanCode(data => {
      emit("scancode", { value: data.value })
    })

    onError(data => {
      showModal({
        title: "隐私权限",
        content: "请在 iPhone 的“设置-隐私”选项中，允许访问你的摄像头。",
        showCancel: false
      })
      emit("error", { errMsg: data.error })
    })

    watch(
      () => props.devicePosition,
      () => {
        update()
      }
    )

    watch(
      () => props.flash,
      () => {
        update()
      }
    )

    watch(
      () => props.resolution,
      () => {
        update()
      }
    )

    onMounted(() => {
      setTimeout(async () => {
        const status = await authorize()
        if (status === AuthorizationStatus.denied) {
          emit("error", { errMsg: "insertCamera: fail auth deny" })
        } else if (status === AuthorizationStatus.authorized) {
          insert()
        }
      })
    })

    const insert = () => {
      insertContainer(success => {
        if (success) {
          JSBridge.invoke("insertCamera", {
            parentId: tongcengKey,
            cameraId,
            mode: props.mode,
            flash: props.flash,
            resolution: props.resolution,
            devicePosition: props.devicePosition
          })
        }
      })
    }

    const update = () => {
      JSBridge.invoke("updateCamera", {
        cameraId,
        flash: props.flash,
        devicePosition: props.devicePosition
      })
    }

    return () => (
      <ek-camera>
        <div ref={tongcengRef} class="ek-native__tongceng" id={tongcengKey}>
          <div style={{ width: "100%", height: tongcengHeight }}></div>
        </div>
      </ek-camera>
    )
  }
})
