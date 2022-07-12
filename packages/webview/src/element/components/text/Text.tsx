import { defineComponent } from "vue"

const props = {
  userSelect: { type: Boolean, default: false }
}

export default defineComponent({
  name: "ek-text",
  props,
  setup() {
    return () => (
      <ek-text>
        <span class="ek-text-content"></span>
      </ek-text>
    )
  }
})
