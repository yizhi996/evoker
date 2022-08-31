import { isString } from "@vue/shared"

export const enum ErrorCodes {
  MISSING_REQUIRED_PRAMAR = 0,
  INVALID_TYPE,
  CANNOT_BE_EMPTY,
  ILLEGAL_VALUE
}

const errorMessages: Record<ErrorCodes, string> = {
  [ErrorCodes.MISSING_REQUIRED_PRAMAR]: "missing required params: ",
  [ErrorCodes.INVALID_TYPE]: "`The ${} must be of type ${}. Received ${url}`",
  [ErrorCodes.CANNOT_BE_EMPTY]: "cannot be empty: ",
  [ErrorCodes.ILLEGAL_VALUE]: "illegal value: "
}

export function errorMessage(code: ErrorCodes, additionalMessage?: string) {
  return errorMessages[code] + (additionalMessage || "")
}

const getNameType = (name: string) => (name.includes(".") ? "property" : "argument")

export const ERR_INVALID_ARG_TYPE = (name: string, types: string | string[], actual: unknown) =>
  `The "${name}" ${getNameType(name)} must be of type ${
    isString(types) ? types : types.join(" or")
  }. Received ${actual}`

export const ERR_CANNOT_EMPTY = "cannot be empty"

export const ERR_INVALID_ARG_VALUE = (
  name: string,
  value: unknown,
  reason: string = "is invalid"
) => `The "${name}" ${getNameType(name)} ${reason}, Received ${value}`
