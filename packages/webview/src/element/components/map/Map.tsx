import { watch, onMounted, defineComponent } from "vue"
import { useTongceng } from "../../composables/useTongceng"
import { useMap } from "../../composables/useMap"
import { JSBridge } from "../../../bridge"

const props = {
  longitude: { type: Number, required: true },
  latitude: { type: Number, required: true },
  scale: { type: Number, default: 16.0 },
  minScale: { type: Number, default: 3.0 },
  maxScale: { type: Number, default: 20.0 },
  showLocation: { type: Boolean, default: false },
  showCompass: { type: Boolean, default: false },
  showScale: { type: Boolean, default: false },
  enableZoom: { type: Boolean, default: false },
  enableScroll: { type: Boolean, default: false },
  enableRotate: { type: Boolean, default: false },
  enableSatellite: { type: Boolean, default: false },
  enableTraffic: { type: Boolean, default: false },
  enableBuilding: { type: Boolean, default: false },
  enable3D: { type: Boolean, default: false }
}

export default defineComponent({
  name: "ev-map",
  props,
  emits: ["updated", "tap", "tappoi", "regionchange"],
  setup(props, { emit }) {
    const {
      tongcengKey,
      nativeId: mapId,
      tongcengRef,
      tongcengHeight,
      insertContainer
    } = useTongceng()

    const { onUpdated, onTap, onTapPoi, onRegionChange } = useMap(mapId)

    onUpdated(() => {
      emit("updated", {})
    })

    onTap(({ longitude, latitude }) => {
      emit("tap", { longitude, latitude })
    })

    onTapPoi(({ name, longitude, latitude }) => {
      emit("tappoi", { name, longitude, latitude })
    })

    onRegionChange(({ type, centerLocation }) => {
      emit("regionchange", { type, centerLocation })
    })

    watch(
      () => [props.longitude, props.latitude],
      ([longitude, latitude]) => {
        update({ longitude, latitude })
      }
    )

    watch(
      () => props.scale,
      newValue => {
        update({ scale: newValue })
      }
    )

    watch(
      () => props.minScale,
      newValue => {
        update({ minScale: newValue })
      }
    )

    watch(
      () => props.maxScale,
      newValue => {
        update({ maxScale: newValue })
      }
    )

    watch(
      () => props.showLocation,
      newValue => {
        update({ showLocation: newValue })
      }
    )

    watch(
      () => props.showCompass,
      newValue => {
        update({ showCompass: newValue })
      }
    )

    watch(
      () => props.showScale,
      newValue => {
        update({ showScale: newValue })
      }
    )

    watch(
      () => props.enableZoom,
      newValue => {
        update({ enableZoom: newValue })
      }
    )

    watch(
      () => props.enableScroll,
      newValue => {
        update({ enableScroll: newValue })
      }
    )

    watch(
      () => props.enableRotate,
      newValue => {
        update({ enableRotate: newValue })
      }
    )

    watch(
      () => props.enableSatellite,
      newValue => {
        update({ enableSatellite: newValue })
      }
    )

    watch(
      () => props.enableTraffic,
      newValue => {
        update({ enableTraffic: newValue })
      }
    )

    watch(
      () => props.enableBuilding,
      newValue => {
        update({ enableBuilding: newValue })
      }
    )

    watch(
      () => props.enable3D,
      newValue => {
        update({ enable3D: newValue })
      }
    )

    onMounted(() => {
      setTimeout(() => {
        insert()
      })
    })

    const insert = () => {
      insertContainer(success => {
        if (success) {
          JSBridge.invoke("insertMap", {
            parentId: tongcengKey,
            mapId,
            longitude: props.longitude,
            latitude: props.latitude,
            scale: props.scale,
            minScale: props.minScale,
            maxScale: props.maxScale,
            showLocation: props.showLocation,
            showCompass: props.showCompass,
            showScale: props.showScale,
            enableZoom: props.enableZoom,
            enableScroll: props.enableScroll,
            enableRotate: props.enableRotate,
            enableSatellite: props.enableSatellite,
            enableTraffic: props.enableTraffic,
            enableBuilding: props.enableBuilding,
            enable3D: props.enable3D
          })
        }
      })
    }

    const update = (params: Record<string, any>) => {
      JSBridge.invoke("updateMap", params)
    }

    return () => (
      <ev-map>
        <div
          ref={tongcengRef}
          class="ev-native__tongceng"
          style="position: absolute"
          id={tongcengKey}
        >
          <div style={{ width: "100%", height: tongcengHeight }}></div>
        </div>
      </ev-map>
    )
  }
})
