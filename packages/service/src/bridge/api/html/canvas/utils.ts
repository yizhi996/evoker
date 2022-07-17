const template = (id: string, script: string) => `(function() { 
  const wrapper = document.getElementById("${id}");
  if (wrapper) {
    const canvas = wrapper.querySelector("canvas");
    ${script}
  }
})()`

const exec = (script: string, webViewId: number) =>
  globalThis.__AppServiceNativeSDK.evalWebView(script, webViewId)

export const execCanvasFunction = (id: string, webViewId: number, func: string) =>
  exec(template(id, func), webViewId)

export const execCanvas2DContextFunction = (id: string, webViewId: number, func: string) =>
  exec(template(id, `const ctx = canvas.getContext("2d");${func}`), webViewId)
