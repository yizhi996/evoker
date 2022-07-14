import { getImageInfo } from "@evoker/bridge"

type ImageEvent = () => void

export class Image {
  _path: string = ""

  _src: string = ""

  _width: number = 0

  _height: number = 0

  onload: ImageEvent | undefined

  onerror: ImageEvent | undefined

  constructor() {}

  get src() {
    return this._src
  }

  set src(value) {
    this._src = value
    this.loadImage()
  }

  get width() {
    return this._width
  }

  get height() {
    return this._height
  }

  private loadImage() {
    if (this._src) {
      getImageInfo({ src: this._src })
        .then(res => {
          this._width = res.width
          this._height = res.height
          this._path = res.path
          this.onload && this.onload()
        })
        .catch(err => {
          this.onerror && this.onerror()
        })
    }
  }
}
