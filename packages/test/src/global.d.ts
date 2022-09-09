interface CGRect {
  x: number
  y: number
  width: number
  height: number
}

interface UIView {
  id: string
  rect: CGRect
  backgroundColor: string
}

interface UIFont {
  size: number
  weight: string
}

interface UILabel extends UIView {
  text: string
  textColor: string
  font: UIFont
}

interface UIButton extends UIView {
  title: string
  titleColor: string
}

interface TestUtils {
  findText(text: string): boolean

  findImage(name: string): boolean

  findFirstResponderInput(): string | undefined

  findUIViewWithClass(className: string): UIView | undefined

  findUIButtonWithTitle(title: string): UIButton | undefined

  findUILabelWithText(text: string): UILabel | undefined

  setInput(id: string, text: string): void

  clickButtonWithId(id: string): void

  clickButtonWithTitle(title: string): void

  clickTableViewCellWithTitle(title: string): void
}

declare global {
  var __TestUtils: TestUtils
}

export {}
