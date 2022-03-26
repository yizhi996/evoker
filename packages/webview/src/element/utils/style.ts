import { rgbToHex } from "./format"

function defaultParseFloat(string: string, def: number = 0): number {
  return parseFloat(string) || def
}

export function getInputStyle(el: HTMLElement) {
  const style = window.getComputedStyle(el)

  const left =
    defaultParseFloat(style.borderLeftWidth) +
    defaultParseFloat(style.paddingLeft)
  const right =
    defaultParseFloat(style.borderRightWidth) +
    defaultParseFloat(style.paddingRight)
  const top =
    defaultParseFloat(style.borderTopWidth) +
    defaultParseFloat(style.paddingTop)
  const bottom =
    defaultParseFloat(style.borderBottomWidth) +
    defaultParseFloat(style.paddingBottom)

  const fontSize = defaultParseFloat(style.fontSize, 16)

  const lineHeight = defaultParseFloat(style.lineHeight)

  const color = rgbToHex(style.color)

  let textAlign = style.textAlign
  if (textAlign === "start") {
    textAlign = "left"
  } else if (textAlign === "end") {
    textAlign = "right"
  } else if (!["left", "center", "right"].includes(textAlign)) {
    textAlign = "left"
  }

  const rect = el.getBoundingClientRect()
  return {
    width: rect.width - left - right,
    height: rect.height - top - bottom,
    color,
    fontSize,
    fontWeight: getFontWeight(style),
    textAlign,
    lineHeight
  }
}

export function getInputPlaceholderStyle(el: HTMLElement) {
  const style = window.getComputedStyle(el)
  return {
    fontSize: defaultParseFloat(style.fontSize, 16),
    fontWeight: getFontWeight(style),
    color: rgbToHex(style.color)
  }
}

function getFontWeight(style: CSSStyleDeclaration) {
  let fontWeight = "normal"
  const fontWeigthNumber = parseInt(style.fontWeight, 10)
  if (isNaN(fontWeigthNumber)) {
    fontWeight = style.fontWeight
  } else if (fontWeigthNumber >= 850) {
    fontWeight = "black"
  } else if (fontWeigthNumber >= 750) {
    fontWeight = "heavy"
  } else if (fontWeigthNumber >= 650) {
    fontWeight = "bold"
  } else if (fontWeigthNumber >= 550) {
    fontWeight = "semibold"
  } else if (fontWeigthNumber >= 450) {
    fontWeight = "medium"
  } else if (fontWeigthNumber >= 350) {
    fontWeight = "normal"
  } else if (fontWeigthNumber >= 250) {
    fontWeight = "light"
  } else if (fontWeigthNumber >= 150) {
    fontWeight = "thin"
  } else {
    fontWeight = "ultraLight"
  }
  return fontWeight
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
