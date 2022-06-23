import { Component } from "vue"

import ScrollView from "./components/scroll-view"
import Swiper from "./components/Swiper/Swiper.vue"
import SwiperItem from "./components/Swiper/SwiperItem.vue"
import Image from "./components/image"
import Video from "./components/video"
import Button from "./components/button"
import Progress from "./components/progress"
import Slider from "./components/slider"
import Navigator from "./components/navigator"
import Switch from "./components/switch"
import Checkbox from "./components/checkbox"
import CheckboxGroup from "./components/checkbox-group"
import Input from "./components/input"
import Icon from "./components/icon"
import Picker from "./components/picker"
import Radio from "./components/radio"
import RadioGroup from "./components/radio-group"
import Camera from "./components/camera"
import MovableArea from "./components/Movable/MovableArea.vue"
import MovableView from "./components/Movable/MovableView.vue"
import TextArea from "./components/textarea"
import Text from "./components/Text.vue"
import Map from "./components/map"
import Canvas from "./components/Canvas.vue"
import View from "./components/view"
import PickerView from "./components/picker-view"
import PickerViewColumn from "./components/picker-view-column"
import Form from "./components/form"
import Label from "./components/label"

import "./index.less"

export interface BuiltInComponent {
  component: Component
  slot?: string
}

const builtInComponent: Record<string, BuiltInComponent> = {
  "scroll-view": {
    component: ScrollView,
    slot: "#content"
  },
  image: { component: Image },
  swiper: { component: Swiper, slot: ".nz-swiper__slide__frame" },
  "swiper-item": { component: SwiperItem },
  button: { component: Button, slot: "#content" },
  video: { component: Video, slot: ".nz-video__slot" },
  progress: { component: Progress },
  slider: { component: Slider },
  navigator: { component: Navigator },
  switch: { component: Switch, slot: ".nz-switch__label" },
  checkbox: { component: Checkbox, slot: ".nz-checkbox__label" },
  "checkbox-group": { component: CheckboxGroup },
  input: { component: Input },
  icon: { component: Icon },
  picker: { component: Picker },
  radio: { component: Radio, slot: ".nz-radio__label" },
  "radio-group": { component: RadioGroup },
  camera: { component: Camera },
  "movable-area": { component: MovableArea },
  "movable-view": { component: MovableView },
  textarea: { component: TextArea },
  text: { component: Text, slot: ".nz-text__content" },
  map: { component: Map },
  canvas: { component: Canvas },
  view: { component: View },
  "picker-view": { component: PickerView, slot: ".nz-picker-view__wrapper" },
  "picker-view-column": {
    component: PickerViewColumn,
    slot: ".nz-picker-view-column__content"
  },
  form: { component: Form },
  label: { component: Label }
}

export function requireBuiltInComponent(tag: string): BuiltInComponent | undefined {
  if (tag === "img") {
    return builtInComponent["image"]
  } else if (tag === "a") {
    return builtInComponent["text"]
  }
  return builtInComponent[tag]
}

export function injectComponent(tag: string, component: Component, slot?: string) {
  builtInComponent[tag] = { component, slot }
}
