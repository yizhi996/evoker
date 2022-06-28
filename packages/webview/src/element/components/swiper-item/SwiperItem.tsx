import { reactive, onMounted, getCurrentInstance, onUnmounted, defineComponent } from "vue"
import { SWIPE_KEY, SwipeProvide } from "../swiper/constant"
import { useParent, ParentProvide } from "../../composables/useRelation"

export default defineComponent({
  name: "ev-swiper-item",
  setup(_, { expose }) {
    const instance = getCurrentInstance()!

    let parent: ParentProvide<SwipeProvide> | undefined

    onMounted(() => {
      setTimeout(() => {
        parent = useParent(instance, SWIPE_KEY)
      })
    })

    onUnmounted(() => {
      parent && parent.unlink(instance)
    })

    let style = reactive<{ width?: string; height?: string; transform?: string }>({})

    expose({
      setStyle: (width: string, height: string, transform: string) => {
        style.width = width
        style.height = height
        style.transform = transform
      },
      setSize: (width: string, height: string) => {
        style.width = width
        style.height = height
      },
      setTransform: (transform: string) => {
        style.transform = transform
      }
    })

    return () => <ev-swiper-item style={style}></ev-swiper-item>
  }
})
