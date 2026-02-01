// See the Tailwind configuration guide for advanced usage
// https://tailwindcss.com/docs/configuration

const plugin = require("tailwindcss/plugin")

module.exports = {
  content: [
    "./js/**/*.js",
    "../lib/lumber_web.ex",
    "../lib/lumber_web/**/*.*ex"
  ],
  theme: {
    borderRadius: {
      none: "0",
      sm: ".25rem",
      DEFAULT: ".5rem",
      lg: "1rem",
      full: "9999px",
    },
    extend: {},
  },
  plugins: [
    require("@tailwindcss/forms"),
    // Allows prefixing tailwind classes with LiveView classes to add transitions
    plugin(({addVariant}) => addVariant("phx-click-loading", [".phx-click-loading&", ".phx-click-loading &"])),
    plugin(({addVariant}) => addVariant("phx-submit-loading", [".phx-submit-loading&", ".phx-submit-loading &"])),
    plugin(({addVariant}) => addVariant("phx-change-loading", [".phx-change-loading&", ".phx-change-loading &"])),
  ]
}
