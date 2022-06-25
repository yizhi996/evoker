import "./dom/vdSync"

import ScrollView from "./element/components/scroll-view/ScrollView"
import Swiper from "./element/components/swiper/Swiper"
import SwiperItem from "./element/components/swiper-item/SwiperItem"
import Image from "./element/components/image/Image"
import Video from "./element/components/video/Video"
import Button from "./element/components/button/Button"
import Progress from "./element/components/progress/Progress"
import Slider from "./element/components/slider/Slider"
import Navigator from "./element/components/navigator/Navigator"
import Switch from "./element/components/switch/Switch"
import Checkbox from "./element/components/checkbox/Checkbox"
import CheckboxGroup from "./element/components/checkbox-group/CheckboxGroup"
import Input from "./element/components/input/Input"
import Icon from "./element/components/icon/Icon"
import Picker from "./element/components/picker/Picker"
import Radio from "./element/components/radio/Radio"
import RadioGroup from "./element/components/radio-group/RadioGroup"
import Camera from "./element/components/camera/Camera"
import MovableArea from "./element/components/movable-area/MovableArea"
import MovableView from "./element/components/movable-view/MovableView"
import TextArea from "./element/components/textarea/Textarea"
import Text from "./element/components/text/Text"
import Map from "./element/components/map/Map"
// import Canvas from "./element/components/Canvas.vue"
import View from "./element/components/view/View"
import PickerView from "./element/components/picker-view/PickerView"
import PickerViewColumn from "./element/components/picker-view-column/PickerViewColumn"
import Form from "./element/components/form/Form"
import Label from "./element/components/label/Label"

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
  // Canvas,
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
