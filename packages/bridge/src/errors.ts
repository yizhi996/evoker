import { isString } from "@vue/shared"

const getNameType = (name: string) => (name.includes(".") ? "property" : "argument")

export const ERR_INVALID_ARG_TYPE = (name: string, types: string | string[], actual: unknown) =>
  `The "${name}" ${getNameType(name)} must be of type ${
    isString(types) ? types : types.join(" or")
  }. Received ${actual}`

export const ERR_CANNOT_EMPTY = "cannot be empty"

export const ERR_INVALID = (name: string) => `${name} invalid`

export const ERR_INVALID_ARG_VALUE = (
  name: string,
  value: unknown,
  reason: string = "is invalid"
) => `The "${name}" ${getNameType(name)} ${reason}, Received ${value}`

export const ERR_OUT_OF_RANGE = (name: string, input: unknown, range: string) =>
  `The value of "${name}" is out of range. It must be ${range}. Received ${input}`
