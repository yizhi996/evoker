export default function useResize(el: HTMLElement) {
  let callback: (rect: DOMRect) => void | undefined

  const onResize = () => {
    callback && callback(el.getBoundingClientRect())
  }

  el.addEventListener("resize", onResize)

  return {
    onResize: (hook: (rect: DOMRect) => void) => {
      callback = hook
      onResize()
    }
  }
}
