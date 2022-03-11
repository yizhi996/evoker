import { invokeCallbackHandler } from "../../src/bridge"
import { getStorage } from "../../src/api/storage"

let cbId = 0

function mock(event: string, result: any) {
  invokeCallbackHandler({
    id: cbId++,
    event,
    errMsg: "",
    data: result
  })
}

describe("getStorage", () => {
  test("get string", () => {
    expect.assertions(1)

    getStorage({ key: "test" }).then(res => {
      expect(res.data).toBe("test string")
    })

    mock("getStorage", { data: "test string", dataType: "String" })
  })

  test("get object", () => {
    expect.assertions(1)

    getStorage({ key: "test" }).then(res => {
      expect(res.data).toEqual({ a: 1, b: "2" })
    })

    mock("getStorage", {
      data: JSON.stringify({ a: 1, b: "2" }),
      dataType: "Object"
    })
  })
})
