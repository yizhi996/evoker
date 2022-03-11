export type ColumnsFieldNames = {
  text?: string
  values?: string
  children?: string
}

export type PickerObjectOption = {
  text?: string | number
  disabled?: boolean
  // for custom filed names
  [key: PropertyKey]: any
}

export type PickerOption = string | number | PickerObjectOption

export type PickerObjectColumn = {
  values?: PickerOption[]
  children?: PickerColumn
  className?: unknown
  defaultIndex?: number
  // for custom filed names
  [key: PropertyKey]: any
}

export type PickerColumn = PickerOption[] | PickerObjectColumn
