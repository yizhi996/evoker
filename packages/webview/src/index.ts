import "./dom/vdSync"

import ScrollView from "./element/components/scroll-view"
import Swiper from "./element/components/swiper"
import SwiperItem from "./element/components/swiper-item"
import Image from "./element/components/image"
import Video from "./element/components/video"
import Button from "./element/components/button"
import Progress from "./element/components/progress"
import Slider from "./element/components/slider"
import Navigator from "./element/components/navigator"
import Switch from "./element/components/switch"
import Checkbox from "./element/components/checkbox"
import CheckboxGroup from "./element/components/checkbox-group"
import Input from "./element/components/input"
import Icon from "./element/components/icon"
import Picker from "./element/components/picker"
import Radio from "./element/components/radio"
import RadioGroup from "./element/components/radio-group"
import Camera from "./element/components/camera"
import MovableArea from "./element/components/movable-area"
import MovableView from "./element/components/movable-view"
import Textarea from "./element/components/textarea"
import Text from "./element/components/text"
import Map from "./element/components/map"
// import Canvas from "./element/components/Canvas.vue"
import View from "./element/components/view"
import PickerView from "./element/components/picker-view"
import PickerViewColumn from "./element/components/picker-view-column"
import Form from "./element/components/form"
import Label from "./element/components/label"

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
  Textarea,
  Text,
  Map,
  // Canvas,
  View,
  PickerView,
  PickerViewColumn,
  Form,
  Label
}

if (window.webkit) {
  window.webkit.messageHandlers.loaded.postMessage({
    timestamp: Date.now()
  })
}
