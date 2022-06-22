import { isArray, isObject, isString } from "@vue/shared"

export function getRandomInt(min: number, max: number) {
  min = Math.ceil(min)
  max = Math.floor(max)
  return Math.floor(Math.random() * (max - min) + min)
}

export function debounce(callback: () => void, delay: number) {
  let timer: ReturnType<typeof setTimeout>
  return function () {
    if (timer) {
      clearTimeout(timer)
    }
    timer = setTimeout(callback, delay)
  }
}

export const enum AuthorizationStatus {
  authorized = 0,
  denied,
  notDetermined
}

export function classNames(...args: unknown[]) {
  const classes: string[] = []

  args.forEach(cls => {
    if (cls) {
      if (isString(cls)) {
        classes.push(cls)
      } else if (isArray(cls)) {
        const clss = classNames(cls)
        clss && classes.push(clss)
      } else if (isObject(cls)) {
        for (const [k, v] of Object.entries(cls)) {
          v && classes.push(k)
        }
      }
    }
  })

  return classes.join(" ")
}
