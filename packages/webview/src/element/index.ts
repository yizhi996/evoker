import { Component } from "vue"

import ScrollView from "./components/scroll-view"
import Swiper from "./components/swiper"
import SwiperItem from "./components/swiper-item"
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
import InputHTML from "./components/input-html"
import Icon from "./components/icon"
import Picker from "./components/picker"
import Radio from "./components/radio"
import RadioGroup from "./components/radio-group"
import Camera from "./components/camera"
import MovableArea from "./components/movable-area"
import MovableView from "./components/movable-view"
import TextArea from "./components/textarea"
import Text from "./components/text"
import Map from "./components/map"
import Canvas from "./components/canvas"
import View from "./components/view"
import PickerView from "./components/picker-view"
import PickerViewColumn from "./components/picker-view-column"
import Form from "./components/form"
import Label from "./components/label"

import "./index.less"
import { isDevtools } from "@evoker/shared"

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
  swiper: { component: Swiper, slot: ".ek-swiper__slide__frame" },
  "swiper-item": { component: SwiperItem },
  button: { component: Button, slot: ".ek-button__text" },
  video: { component: Video, slot: ".ek-video__slot" },
  progress: { component: Progress },
  slider: { component: Slider },
  navigator: { component: Navigator },
  switch: { component: Switch, slot: ".ek-switch__label" },
  checkbox: { component: Checkbox, slot: ".ek-checkbox__label" },
  "checkbox-group": { component: CheckboxGroup },
  input: { component: isDevtools ? InputHTML : Input },
  icon: { component: Icon },
  picker: { component: Picker },
  radio: { component: Radio, slot: ".ek-radio__label" },
  "radio-group": { component: RadioGroup },
  camera: { component: Camera },
  "movable-area": { component: MovableArea },
  "movable-view": { component: MovableView },
  textarea: { component: TextArea },
  text: { component: Text, slot: ".ek-text__content" },
  map: { component: Map },
  view: { component: View },
  "picker-view": { component: PickerView, slot: ".ek-picker-view__wrapper" },
  "picker-view-column": {
    component: PickerViewColumn,
    slot: ".ek-picker-view-column__content"
  },
  form: { component: Form },
  label: { component: Label },
  canvas: { component: Canvas }
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
