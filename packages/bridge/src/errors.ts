export const enum ErrorCodes {
  MISSING_REQUIRED_PRAMAR = 0,
  CANNOT_BE_EMPTY,
  ILLEGAL_VALUE
}

const errorMessages: Record<ErrorCodes, string> = {
  [ErrorCodes.MISSING_REQUIRED_PRAMAR]: "missing required params: ",
  [ErrorCodes.CANNOT_BE_EMPTY]: "cannot be empty: ",
  [ErrorCodes.ILLEGAL_VALUE]: "illegal value: "
}

export function errorMessage(code: ErrorCodes, additionalMessage?: string) {
  return errorMessages[code] + (additionalMessage || "")
}
