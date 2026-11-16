return {
  {
    "omacom/aether.nvim",
    branch = "v3",
    name = "aether",
    priority = 1000,
    opts = {
      colors = {
        bg = "#100600",
        dark_bg = "#060200",
        darker_bg = "#060200",
        lighter_bg = "#1b0c02",

        fg = "#ff6b08",
        dark_fg = "#dd5800",
        light_fg = "#ffa86d",
        bright_fg = "#ffa86d",
        muted = "#5b2500",

        red = "#ff0043",
        yellow = "#ffa86d",
        orange = "#ff6b08",
        green = "#ff6b08",
        cyan = "#ab4500",
        blue = "#ab4500",
        magenta = "#ab4500",
        brown = "#5b2500",

        bright_red = "#ff465a",
        bright_yellow = "#ffa86d",
        bright_green = "#00b05b",
        bright_cyan = "#dd5800",
        bright_blue = "#dd5800",
        bright_magenta = "#dd5800",

        accent = "#ff6b08",
        cursor = "#ffa86d",
        foreground = "#ff6b08",
        background = "#100600",
        selection = "#5b2500",
        selection_foreground = "#1e0c00",
        selection_background = "#ff6b08",
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "aether",
    },
  },
}
