-- lumon.nvim with its palette swapped for AmberConsole neon tokens,
-- each in its documented role. Halos are glow-only, so none appear here.
local screen, raised = "#100600", "#1b0c02"
local e100, e90, e70, e50, e30 = "#ffa86d", "#ff6b08", "#dd5800", "#ab4500", "#5b2500"

return {
  {
    "omacom-io/lumon.nvim",
    priority = 1000,
    opts = {
      colors = {
        -- surfaces: editor is the base panel; sidebars/floats/statusline are lifted
        bg = screen,
        bg_dark = raised,
        bg_dark1 = raised,
        bg_highlight = e30,

        -- ink
        fg = e90,
        fg_dark = e70,
        comment = e50,
        dark5 = e70,

        -- trace / decorative
        fg_gutter = e30,
        dark3 = e30,
        terminal_black = e30,
        blue0 = e30,
        blue7 = e30,

        -- highlight / focus
        blue = e100,
        blue1 = e100,
        blue2 = e100,
        blue5 = e100,
        blue6 = e100,
        cyan = e100,
        teal = e100,
        special_char = e100,

        -- primary
        orange = e90,
        yellow = e90,

        -- secondary
        green = e70,
        green1 = e70,
        green2 = e70,
        magenta = e70,
        magenta2 = e70,
        purple = e70,

        -- alarm takes the hottest stop
        red = e100,
        red1 = e100,
      },
    },
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "lumon",
    },
  },
}
