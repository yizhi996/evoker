import { InjectionKey } from "vue"

export interface CheckboxProvide {
  onChecked: (value: string, checked: boolean, dispatch: boolean) => void
}

export const CHECKBOX_GROUP_KEY: InjectionKey<CheckboxProvide> =
  Symbol("checkboxGroup")
