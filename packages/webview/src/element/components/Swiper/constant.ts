import { ComputedRef, InjectionKey } from "vue"

export type SwipeProvide = {
  count: ComputedRef<number>
}

export const SWIPE_KEY: InjectionKey<SwipeProvide> = Symbol("swiper")
