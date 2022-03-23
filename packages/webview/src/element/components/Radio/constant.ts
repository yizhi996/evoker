import { InjectionKey } from "vue"

export interface RadioProvide {
  onChecked: (value: string, dispatch: boolean) => void
}

export const RADIO_GROUP_KEY: InjectionKey<RadioProvide> = Symbol("radioGroup")
