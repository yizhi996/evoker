const DOMGlobals = ["window", "document"]
const NodeGlobals = ["module", "require"]

module.exports = {
  parser: "@typescript-eslint/parser",
  parserOptions: {
    sourceType: "module"
  },
  rules: {
    "no-unused-vars": ["error", { varsIgnorePattern: ".*", args: "none" }],
    "no-restricted-globals": ["error", ...DOMGlobals, ...NodeGlobals],
    "no-restricted-syntax": [
      "error",
      "ObjectExpression > SpreadElement",
      "ObjectPattern > RestElement",
      "AwaitExpression"
    ],
    quotes: ["error", "double", { allowTemplateLiterals: true }],
    semi: ["error", "never"]
  },
  overrides: [
    {
      files: ["**/__tests__/**", "test-dts/**"],
      rules: {
        "no-restricted-globals": "off",
        "no-restricted-syntax": "off"
      }
    },
    {
      files: ["packages/plugin/**"],
      rules: {
        "no-restricted-globals": ["error", ...DOMGlobals]
      }
    },
    {
      files: ["packages/webview/**"],
      rules: {
        "no-restricted-globals": ["error", ...NodeGlobals]
      }
    }
  ],
  ignorePatterns: ["**/dist/**", "*.d.ts"]
}
