import { rgbToHex } from "./format"

export function getInputStyle(e: HTMLElement) {
  const style = window.getComputedStyle(e)

  const fontSize = parseFloat(style.fontSize) || 16.0

  const lineHeight = parseFloat(style.lineHeight) || 0

  const color = rgbToHex(style.color)

  let textAlign = style.textAlign
  if (textAlign === "start") {
    textAlign = "left"
  } else if (textAlign === "end") {
    textAlign = "right"
  } else if (!["left", "center", "right"].includes(textAlign)) {
    textAlign = "left"
  }

  let fontWeight = "normal"
  const fontWeigthNumber = parseInt(style.fontWeight, 10)
  if (isNaN(fontWeigthNumber)) {
    fontWeight = style.fontWeight
  } else if (fontWeigthNumber < 500) {
    fontWeight = "normal"
  } else {
    fontWeight = "bold"
  }

  return {
    color,
    fontSize,
    fontWeight,
    textAlign,
    lineHeight
  }
}

export function getInputPlaceholderStyle(e: HTMLElement) {
  const style = window.getComputedStyle(e)
  let fontWeight = "normal"
  const fontWeigthNumber = parseInt(style.fontWeight, 10)
  if (isNaN(fontWeigthNumber)) {
    fontWeight = style.fontWeight
  } else if (fontWeigthNumber < 500) {
    fontWeight = "normal"
  } else {
    fontWeight = "bold"
  }
  return {
    fontSize: parseFloat(style.fontSize) || 16,
    fontWeight,
    color: rgbToHex(style.color)
  }
}

export type ImageMode =
  | "scaleToFill"
  | "aspectFit"
  | "aspectFill"
  | "widthFix"
  | "heightFix"
  | "top"
  | "bottom"
  | "center"
  | "left"
  | "right"
  | "topleft"
  | "topright"
  | "bottomleft"
  | "bottomright"

const imageModeStyle: Record<ImageMode, string> = {
  scaleToFill: "background-size: 100% 100%;",
  aspectFit: "background-size: contain;background-position: center center;",
  aspectFill: "background-size: cover;background-position: center center;",
  widthFix: "background-size: cover;background-position: center center;",
  heightFix: "background-size: 100% 100%;background-position: center center;",
  top: "background-position: center top;",
  bottom: "background-position: center bottom;",
  center: "background-position: center center;",
  left: "background-position: left center;",
  right: "background-position: right center;",
  topleft: "background-position: left top;",
  topright: "background-position: right top;",
  bottomleft: "background-position: left bottom;",
  bottomright: "background-position: bottom bottom;"
}

export function getImageModeStyleCssText(mode: ImageMode) {
  const css = imageModeStyle[mode] || imageModeStyle["scaleToFill"]
  return css + "background-repeat: no-repeat;"
}
