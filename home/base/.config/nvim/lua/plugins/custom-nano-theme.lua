local omarchy_theme = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")
if vim.fn.filereadable(omarchy_theme) == 1 then
  return {}
end

return {
  {
    "ronisbr/nano-theme.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      vim.opt.background = "dark"

      local amber = require("nano-theme.colors.amber")
      local build_colors = require("nano-theme.colors.utils").build_colors

      amber.dark = function()
        return build_colors({
          nano_foreground_color = "#d97706",
          nano_background_color = "#0c0a09",
          nano_highlight_color = "#451a03",
          nano_subtle_color = "#451a03",
          nano_veryfaded_color = "#78350f",
          nano_faded_color = "#92400e",
          nano_salient_color = "#f59e0b",
          nano_strong_color = "#fbbf24",
          nano_popout_color = "#ea580c",
          nano_critical_color = "#ef4444",

          ansi = {
            black = "#2d1901",
            red = "#dc2626",
            green = "#059669",
            yellow = "#eab308",
            blue = "#2563eb",
            magenta = "#c026d3",
            cyan = "#0891b2",
          },
        })
      end

      require("nano-theme").setup({
        dark_variant = "amber",
      })

      package.loaded["nano-theme.colors"] = nil
      vim.cmd.colorscheme("nano-theme")
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nano-theme",
    },
  },
}
