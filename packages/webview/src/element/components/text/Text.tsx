import { defineComponent } from "vue"

const props = {
  userSelect: { type: Boolean, default: false }
}

export default defineComponent({
  name: "nz-text",
  props,
  setup() {
    return () => (
      <nz-text>
        <span class="nz-text-content"></span>
      </nz-text>
    )
  }
})
