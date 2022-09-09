interface CGRect {
  x: number
  y: number
  width: number
  height: number
}

interface UITextView {
  text: string
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
  click(): void
}

interface UITextView extends UIView {}

interface UITextField extends UIView {}

interface TestUtils {
  containText(text: string): boolean

  containImage(name: string): boolean

  findFirstResponderInput(): UITextView | undefined

  findUIViewWithClass(className: string): UIView | undefined

  findUIButtonWithTitle(title: string): UIButton | undefined

  findUILabelWithText(text: string): UILabel | undefined

  clickTableViewCellWithTitle(title: string): void
}

declare global {
  var __TestUtils: TestUtils
}

export {}
