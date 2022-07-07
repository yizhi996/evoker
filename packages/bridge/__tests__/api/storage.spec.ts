import { invokeCallbackHandler } from "../../src/bridge"
import { getStorage } from "../../src/api/storage"
import { describe, test, expect } from "vitest"

let cbId = 0

function cb(event: string, result: any, errMsg: string = "") {
  invokeCallbackHandler({
    id: cbId++,
    event,
    errMsg: errMsg,
    data: result
  })
}

function success(event: string, result: any) {
  cb(event, result)
}

function fail(event: string, errMsg: string) {
  cb(event, null, errMsg)
}

describe("getStorage", () => {
  test("get string", () => {
    getStorage({ key: "test" }).then(res => {
      expect(res.data).toBe("test string")
    })

    success("getStorage", { data: "test string", dataType: "String" })
  })

  test("get object", () => {
    getStorage({ key: "test" }).then(res => {
      expect(res.data).toEqual({ a: 1, b: "2" })
    })

    success("getStorage", {
      data: JSON.stringify({ a: 1, b: "2" }),
      dataType: "Object"
    })
  })
})
