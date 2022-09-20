module.exports = {
  content: ["./src/**/*.{vue,js,ts,jsx,tsx}"],
  darkMode: "media",
  theme: {
    extend: {
      minWidth: {
        "1/3": "33.333333%"
      },
      minHeight: {
        6: "1.5rem",
        10: "2.5rem"
      },
      maxWidth: {
        "1/3": "33.333333%"
      }
    }
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
