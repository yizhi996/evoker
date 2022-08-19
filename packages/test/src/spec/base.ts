import { describe } from "../test"

describe("base", ctx => {
  ctx.test("env", () => {
    const usr = ek.env.USER_DATA_PATH
    ctx.expect(usr).toBe("ekfile://usr")
  })

  ctx.test("base64", () => {
    const base64 = "CxYh"
    const arrayBuffer = ek.base64ToArrayBuffer(base64)
    const _base64 = ek.arrayBufferToBase64(arrayBuffer)
    ctx.expect(base64).toBe(_base64)
  })
})
