// interface ObserverCallback {
//   id: string
//   dataset: Record<string, any>
//   intersectionRatio: number
//   intersectionRect: Rect
//   relativeRect: Rect
//   time: number
// }

// interface Rect {
//   left: number
//   right: number
//   top: number
//   bottom: number
//   width: number
//   height: number
// }

// interface Margin {
//   left: number
//   right: number
//   top: number
//   bottom: number
// }

// class IntersectionObserver {
//   options: IntersectionObserverOptions
//   constructor(options: IntersectionObserverOptions) {
//     this.options = options
//   }

//   observe(targetSelector: string, callback: ObserverCallback): Promise<string> {
//     return new Promise((resolve, reject) => {
//       InnerJSBridge.invoke(
//         "operateCamera",
//         { cameraId: 1, method: "takePhoto", data: { quality } },
//         result => {
//           if (result.errMsg) {
//             reject(result.errMsg)
//           } else {
//             resolve(result.data)
//           }
//         }
//       )
//     })
//   }

//   disconnect(): Promise<void> {
//     return new Promise((resolve, reject) => {
//       InnerJSBridge.invoke(
//         "operateCamera",
//         { cameraId: 1, method: "startRecord", data: {} },
//         result => {
//           if (result.errMsg) {
//             reject(result.errMsg)
//           } else {
//             resolve(result.data)
//           }
//         }
//       )
//     })
//   }

//   relativeTo(selector: string, margins: Margin): IntersectionObserver {
//     return new Promise((resolve, reject) => {
//       InnerJSBridge.invoke(
//         "operateCamera",
//         { cameraId: 1, method: "stopRecord", data: { compressed } },
//         result => {
//           if (result.errMsg) {
//             reject(result.errMsg)
//           } else {
//             resolve(result.data)
//           }
//         }
//       )
//     })
//   }

//   relativeToViewport(margins: Margin): IntersectionObserver {
//     return new Promise((resolve, reject) => {
//       InnerJSBridge.invoke(
//         "operateCamera",
//         { cameraId: 1, method: "setZoom", data: { zoom } },
//         result => {
//           if (result.errMsg) {
//             reject(result.errMsg)
//           } else {
//             resolve(result.data)
//           }
//         }
//       )
//     })
//   }
// }

// interface IntersectionObserverOptions {
//   thresholds?: number[]
//   initialRatio?: number
//   observeAll?: boolean
// }

// export function createIntersectionObserver(
//   options?: IntersectionObserverOptions
// ): IntersectionObserver {
//   const defaultOptions: IntersectionObserverOptions = {
//     thresholds: [0],
//     initialRatio: 0,
//     observeAll: false
//   }
//   extend(defaultOptions, options)
//   return new IntersectionObserver(defaultOptions)
// }
