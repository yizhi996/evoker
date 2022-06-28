import { defineComponent } from "vue"

const props = {
  userSelect: { type: Boolean, default: false }
}

export default defineComponent({
  name: "ev-text",
  props,
  setup() {
    return () => (
      <ev-text>
        <span class="ev-text-content"></span>
      </ev-text>
    )
  }
})
