module.exports = {
  content: ["./src/**/*.{vue,js,ts,jsx,tsx}"],
  darkMode: "media",
  theme: {
    extend: {}
  },
  variants: {
    extend: {
      backgroundColor: ["active"],
      margin: ["first", "last"],
      padding: ["first", "last"],
      border: ["last"]
    }
  },
  plugins: []
}
