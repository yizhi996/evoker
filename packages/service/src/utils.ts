export function randomId() {
  return ramdomString(6)
}

export function ramdomString(length: number) {
  let result = ""
  let characters = "abcdefghijklmnopqrstuvwxyz0123456789"
  const charactersLength = characters.length
  for (let i = 0; i < length; i++) {
    result += characters.charAt(Math.floor(Math.random() * charactersLength))
  }
  return result
}
