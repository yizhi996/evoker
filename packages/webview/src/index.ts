import "./dom/vdSync"

import Swiper from "./element/components/Swiper/Swiper.vue"
import ScrollView from "./element/components/ScrollView.vue"
import SwiperItem from "./element/components/Swiper/SwiperItem.vue"
import Image from "./element/components/Image.vue"
import Video from "./element/components/Video.vue"
import Button from "./element/components/Button.vue"
import Progress from "./element/components/Progress.vue"
import Slider from "./element/components/Slider.vue"
import Navigator from "./element/components/Navigator.vue"
import Switch from "./element/components/Switch.vue"
import Checkbox from "./element/components/Checkbox/Checkbox.vue"
import CheckboxGroup from "./element/components/Checkbox/CheckboxGroup.vue"
import Input from "./element/components/Input.vue"
import Icon from "./element/components/Icon.vue"
import Picker from "./element/components/Picker/Picker.vue"
import Radio from "./element/components/Radio/Radio.vue"
import RadioGroup from "./element/components/Radio/RadioGroup.vue"
import Camera from "./element/components/Camera.vue"
import MovableArea from "./element/components/Movable/MovableArea.vue"
import MovableView from "./element/components/Movable/MovableView.vue"
import TextArea from "./element/components/TextArea.vue"
import Text from "./element/components/Text.vue"
import Map from "./element/components/Map.vue"
import Canvas from "./element/components/Canvas.vue"
import View from "./element/components/View.vue"
import PickerView from "./element/components/Picker/PickerView.vue"
import PickerViewColumn from "./element/components/Picker/PickerViewColumn.vue"
import Form from "./element/components/Form.vue"
import Label from "./element/components/Label.vue"

export {
  Swiper,
  ScrollView,
  SwiperItem,
  Image,
  Video,
  Button,
  Progress,
  Slider,
  Navigator,
  Switch,
  Checkbox,
  CheckboxGroup,
  Input,
  Icon,
  Picker,
  Radio,
  RadioGroup,
  Camera,
  MovableArea,
  MovableView,
  TextArea,
  Text,
  Map,
  Canvas,
  View,
  PickerView,
  PickerViewColumn,
  Form,
  Label
}

document.addEventListener("DOMContentLoaded", () => {
  if (window.webkit) {
    window.webkit.messageHandlers.DOMContentLoaded.postMessage({
      timestamp: Date.now()
    })
  }
})
