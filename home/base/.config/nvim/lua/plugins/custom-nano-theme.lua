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
      vim.opt.termguicolors = true
      vim.opt.background = "dark"

      local amber = require("nano-theme.colors.amber")
      local build_colors = require("nano-theme.colors.utils").build_colors

      rawset(amber, "dark", function()
        return build_colors({
          nano_foreground_color = "#d97706",
          nano_background_color = "#0c0a09",
          nano_highlight_color = "#1d1816",
          nano_subtle_color = "#2b2422",
          nano_veryfaded_color = "#451a03",
          nano_faded_color = "#92400e",
          nano_salient_color = "#f59e0b",
          nano_strong_color = "#d97706",
          nano_popout_color = "#ea580c",
          nano_critical_color = "#ef4444",

          ansi = {
            black = "#0c0a09",
            red = "#dc2626",
            green = "#059669",
            yellow = "#f59e0b",
            blue = "#2563eb",
            magenta = "#d97706",
            cyan = "#0891b2",
          },
        })
      end)

      require("nano-theme").setup({
        dark_variant = "amber",
        transparent = true,
        transparent_floats = false,
        float_blend = 0,
      })

      package.loaded["nano-theme.colors"] = nil
      vim.cmd.colorscheme("nano-theme")

      for _, group in ipairs({
        "TelescopeNormal",
        "TelescopePromptNormal",
        "TelescopeResultsNormal",
        "TelescopePreviewNormal",
      }) do
        vim.api.nvim_set_hl(0, group, { link = "NormalFloat" })
      end
    end,
  },
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "nano-theme",
    },
  },
}
