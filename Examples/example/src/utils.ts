export function formatSecond(time: number) {
  if (typeof time !== "number" || time < 0) {
    return time
  }

  const hour = Math.floor(time / 3600)
  time %= 3600
  const minute = Math.floor(time / 60)
  time = Math.floor(time % 60)
  const second = time

  return [hour, minute, second]
    .map(x => {
      const y = x.toString()
      return y[1] ? y : "0" + y
    })
    .join(":")
}

export function ramdomString(length: number) {
  let result = ""
  let characters = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"
  const charactersLength = characters.length
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength))
  }
  return result
}
