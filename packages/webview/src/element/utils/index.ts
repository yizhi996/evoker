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
