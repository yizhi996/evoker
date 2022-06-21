import { Component } from "vue"

import ScrollView from "./components/ScrollView.vue"
import Swiper from "./components/Swiper/Swiper.vue"
import SwiperItem from "./components/Swiper/SwiperItem.vue"
import Image from "./components/Image"
import Video from "./components/Video.vue"
import Button from "./components/Button"
import Progress from "./components/Progress.vue"
import Slider from "./components/Slider.vue"
import Navigator from "./components/Navigator.vue"
import Switch from "./components/Switch.vue"
import Checkbox from "./components/Checkbox/Checkbox.vue"
import CheckboxGroup from "./components/Checkbox/CheckboxGroup.vue"
import Input from "./components/Input.vue"
import Icon from "./components/Icon.vue"
import Picker from "./components/Picker/Picker.vue"
import Radio from "./components/Radio/Radio.vue"
import RadioGroup from "./components/Radio/RadioGroup.vue"
import Camera from "./components/Camera.vue"
import MovableArea from "./components/Movable/MovableArea.vue"
import MovableView from "./components/Movable/MovableView.vue"
import TextArea from "./components/TextArea.vue"
import Text from "./components/Text.vue"
import Map from "./components/Map.vue"
import Canvas from "./components/Canvas.vue"
import View from "./components/View.vue"
import PickerView from "./components/Picker/PickerView.vue"
import PickerViewColumn from "./components/Picker/PickerViewColumn.vue"
import Form from "./components/Form.vue"
import Label from "./components/Label.vue"

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
