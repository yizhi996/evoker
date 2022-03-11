import { InjectionKey } from "vue"

export interface RadioProvide {
  updateGroupChecked: (name: unknown) => void
}

export const RADIO_GROUP_KEY: InjectionKey<RadioProvide> = Symbol("radioGroup")
