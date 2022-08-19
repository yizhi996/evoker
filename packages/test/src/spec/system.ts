import { describe } from "../test"

describe("system", ctx => {
  ctx.test("window", () => {
    const info = ek.getWindowInfo()
    ctx.expect(info).not.toBeNull()
  })

  ctx.test("setting", () => {
    const setting = ek.getSystemSetting()
    ctx.expect(setting).not.toBeNull()
  })

  ctx.test("device", () => {
    const info = ek.getDeviceInfo()
    ctx.expect(info).not.toBeNull()
  })

  ctx.test("app", () => {
    const info = ek.getAppBaseInfo()
    ctx.expect(info).not.toBeNull()
  })

  ctx.test("auth", () => {
    const setting = ek.getAppAuthorizeSetting()
    ctx.expect(setting).not.toBeNull()
  })

  ctx.test("system", async () => {
    const setting = await ek.getSystemInfo({})
    ctx.expect(setting).not.toBeNull()
  })
})
