interface Button {
  id: string
  title: string
  titleColor: string
}

interface TestUtils {
  findText(text: string): boolean

  findImage(name: string): boolean

  findButton(title: string): Button | undefined

  findFirstResponderInput(): string | undefined

  setInput(id: string, text: string): void

  clickButtonWithId(id: string): void

  clickButtonWithTitle(title: string): void

  clickTableViewCellWithTitle(title: string): void
}

declare global {
  var __TestUtils: TestUtils
}

export {}
