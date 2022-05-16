import { InjectionKey } from "vue"

export interface PickerViewProvide {
  onChange: () => void
  onPickStart: () => void
  onPickEnd: () => void
}

export const PICKER_VIEW_KEY: InjectionKey<PickerViewProvide> = Symbol("picker-view")
