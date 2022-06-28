export * from "@evoker/service"

declare global {
  var ev: typeof import("@evoker/service").global
}

import {
  Button,
  Camera,
  Checkbox,
  CheckboxGroup,
  Form,
  Icon,
  Image,
  Input,
  Label,
  Map,
  MovableArea,
  MovableView,
  Navigator,
  Picker,
  PickerView,
  PickerViewColumn,
  Progress,
  Radio,
  RadioGroup,
  ScrollView,
  Slider,
  Swiper,
  SwiperItem,
  Switch,
  Text,
  Textarea,
  Video,
  View
} from "@evoker/webview"

declare module "@vue/runtime-core" {
  export interface GlobalComponents {
    Button: typeof Button
    Camera: typeof Camera
    Checkbox: typeof Checkbox
    CheckboxGroup: typeof CheckboxGroup
    Form: typeof Form
    Icon: typeof Icon
    Image: typeof Image
    Input: typeof Input
    Label: typeof Label
    Map: typeof Map
    MovableArea: typeof MovableArea
    MovableView: typeof MovableView
    Navigator: typeof Navigator
    Picker: typeof Picker
    PickerView: typeof PickerView
    PickerViewColumn: typeof PickerViewColumn
    Progress: typeof Progress
    Radio: typeof Radio
    RadioGroup: typeof RadioGroup
    ScrollView: typeof ScrollView
    Slider: typeof Slider
    Swiper: typeof Swiper
    SwiperItem: typeof SwiperItem
    Switch: typeof Switch
    Text: typeof Text
    Textarea: typeof Textarea
    Video: typeof Video
    View: typeof View
  }
}

export {}
