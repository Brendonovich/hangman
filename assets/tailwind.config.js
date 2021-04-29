const colors = require("tailwindcss/colors");

module.exports = {
  purge: {
    enabled: true,
    content: [
      "../lib/**/*.ex",
      "../lib/**/*.leex",
      "../lib/**/*.eex",
      "./js/**/*.js",
    ],
  },
  theme: {
    extend: {
      colors: {
        gray: colors.trueGray,
      },
      gridTemplateColumns: {
        13: "repeat(13, minmax(0, 1fr))",
      },
    },
  },
  variants: {},
  plugins: [require("tailwindcss-phx-live")],
};
