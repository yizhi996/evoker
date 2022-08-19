import { describe } from "../test"

describe("request", async ctx => {
  ctx.test("get", async () => {
    ek.request({
      url: "https://lilithvue.com/api/test",
      data: { id: "100" },
      success: res => {
        const data = res.data as any
        ctx.expect(data.query.id).toBe("100")
      }
    })
  })

  ctx.test("post", async () => {
    ek.request({
      url: "https://lilithvue.com/api/test",
      method: "POST",
      data: { id: "100" },
      success: res => {
        const data = res.data as any
        ctx.expect(data.body.id).toBe("100")
      }
    })
  })
})

describe("download", async ctx => {
  ctx.test("download", async () => {
    ek.downloadFile({
      url: "https://file.lilithvue.com/lilith-test-assets/wallhaven-43y68y.jpg?imageMogr2/thumbnail/512x",
      filePath: ek.env.USER_DATA_PATH + "/test_img.jpg",
      success: res => {
        ctx.expect(res.filePath).toContain("test_img.jpg")
      }
    })
  })
})

describe("web socket", async ctx => {
  ctx.test("send", async () => {
    const ws = ek.connectSocket({ url: "wss://lilithvue.com/echo" })!
    ws.onOpen(() => {
      ws.send({ data: "hello" })
    })

    ws.onMessage(res => {
      ws.close()
      ctx.expect(res.data).toBe("hello")
    })
  })
})
