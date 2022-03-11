export function zeroPad(nr: number, base: number) {
  var len = String(base).length - String(nr).length + 1
  return len > 0 ? new Array(len).join("0") + nr : nr.toString()
}

export function secondsToHoursMinutesSeconds(seconds: number) {
  return [
    Math.floor(seconds / 3600),
    Math.floor((seconds % 3600) / 60),
    Math.floor((seconds % 3600) % 60)
  ]
}

export function secondsToDuration(seconds: number) {
  const [h, m, s] = secondsToHoursMinutesSeconds(seconds)
  let result = `${zeroPad(m, 10)}:${zeroPad(s, 10)}`
  if (h) {
    result = `${zeroPad(h, 10)}:${result}`
  }
  return result
}

export function rgbToHex(rgb: string) {
  let color = rgb
  if (!color) {
    color = "#000000"
  } else if (!color.startsWith("#")) {
    const match = color.match(/\d+/g)
    if (match) {
      let arr: string[] = []
      match.map(function (e, t) {
        if (t < 3) {
          let n = parseInt(e, 10).toString(16)
          if (n.length == 1) {
            n = "0".concat(n)
          }
          arr.push(n)
        }
        return e
      })
      color = "#" + arr.join("")
    } else {
      color = "#000000"
    }
  }
  return color
}

// from vant/utils/format
let rootFontSize: number

function getRootFontSize() {
  if (!rootFontSize) {
    const doc = document.documentElement
    const fontSize = doc.style.fontSize || window.getComputedStyle(doc).fontSize

    rootFontSize = parseFloat(fontSize)
  }

  return rootFontSize
}

function convertRem(value: string) {
  value = value.replace(/rem/g, "")
  return +value * getRootFontSize()
}

function convertVw(value: string) {
  value = value.replace(/vw/g, "")
  return (+value * window.innerWidth) / 100
}

function convertVh(value: string) {
  value = value.replace(/vh/g, "")
  return (+value * window.innerHeight) / 100
}

export function unitToPx(value: string | number): number {
  if (typeof value === "number") {
    return value
  }

  if (value.includes("rem")) {
    return convertRem(value)
  }
  if (value.includes("vw")) {
    return convertVw(value)
  }
  if (value.includes("vh")) {
    return convertVh(value)
  }
  // TODO
  // if (value.includes("rpx")) {

  // }

  return parseFloat(value)
}
