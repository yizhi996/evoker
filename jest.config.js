module.exports = {
  rootDir: __dirname,
  testEnvironment: "jsdom",
  preset: "ts-jest",
  globals: {
    "ts-jest": {
      tsconfig: {
        target: "esnext",
        sourceMap: true
      }
    },
    "vue-jest": {
      compilerOptions: {
        isCustomElement: tag => tag.startsWith("ll-")
      }
    }
  },
  watchPathIgnorePatterns: ["/node_modules/", "/dist/", "/.git/"],
  moduleFileExtensions: ["ts", "tsx", "js", "json", "vue"],
  transform: {
    "^.+\\.vue$": "@vue/vue3-jest"
  },
  moduleNameMapper: {},
  testMatch: ["<rootDir>/packages/**/__tests__/**/*spec.[jt]s?(x)"],
  testPathIgnorePatterns: process.env.SKIP_E2E
    ? // ignore example tests on netlify builds since they don't contribute
      // to coverage and can cause netlify builds to fail
      ["/node_modules/", "/examples/__tests__"]
    : ["/node_modules/"]
}
