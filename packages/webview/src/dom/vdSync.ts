import { SyncFlags } from "@nzoth/shared"
import { pipeline } from "@nzoth/bridge"
import {
  insertBefore,
  setText,
  removeChild,
  setDisplay,
  addEventListener,
  updateProp,
  setModelValue
} from "./render"

pipeline.onSync(message => {
  message.forEach((action: any[]) => {
    invoke(action)
  })
})

const invokeFunction: { [x: number]: Function } = {
  [SyncFlags.INSERT]: insertBefore,
  [SyncFlags.SET_TEXT]: setText,
  [SyncFlags.REMOVE]: removeChild,
  [SyncFlags.DISPLAY]: setDisplay,
  [SyncFlags.ADD_EVENT]: addEventListener,
  [SyncFlags.UPDATE_PROP]: updateProp,
  [SyncFlags.SET_MODEL_VALUE]: setModelValue
}

function invoke(data: any[]) {
  const flag = data[0] as SyncFlags
  const fn = invokeFunction[flag]
  fn && fn(data)
}
