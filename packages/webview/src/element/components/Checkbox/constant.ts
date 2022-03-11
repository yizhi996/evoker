import { InjectionKey } from "vue"

export interface CheckboxProvide {
  updateGroupChecked: (x: unknown) => void
}

export const CHECKBOX_GROUP_KEY: InjectionKey<CheckboxProvide> =
  Symbol("checkboxGroup")
