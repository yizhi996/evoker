import { ComputedRef, InjectionKey } from "vue"

export interface MovableProvide {
  count: ComputedRef<number>
  areaSize: {
    width: number
    height: number
  }
}

export const MOVABLE_KEY: InjectionKey<MovableProvide> = Symbol("movable")
