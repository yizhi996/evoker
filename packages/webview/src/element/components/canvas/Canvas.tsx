import { defineComponent, ref, PropType, onMounted, onUnmounted, nextTick } from "vue"
import { getRandomInt } from "../../utils"
import { useCanvas2D } from "../../composables/useCanvas2D"

const props = {
  type: {
    type: String as PropType<"2d" | "webgl">,
    default: "2d"
  }
}

export default defineComponent({
  name: "ek-canvas",
  props,
  setup(props, { emit, expose }) {
    const canvasId = getRandomInt(10000, 10000000)

    const canvas = ref<HTMLCanvasElement>()

    const ctx = ref<CanvasRenderingContext2D | null>()

    const { exec, destroy } = useCanvas2D(ctx)

    onMounted(async () => {
      await nextTick()
      ctx.value = canvas.value!.getContext("2d")
    })

    onUnmounted(() => {
      destroy()
    })

    const defineMethods = {
      SET_WIDTH: (data: Record<string, any>) => {
        canvas.value!.width = data.value
      },
      SET_HEIGHT: (data: Record<string, any>) => {
        canvas.value!.height = data.value
      }
    }

    expose({
      getCanvasId: () => canvasId,
      exec: ({ commands }) => {
        exec(commands)
      },
      operate: ({ method, data }) => {
        const fn = defineMethods[method]
        fn && fn(data)
      }
    })

    return () => (
      <ek-canvas>
        <canvas ref={canvas} class="ek-canvas__inner"></canvas>
      </ek-canvas>
    )
  }
})
