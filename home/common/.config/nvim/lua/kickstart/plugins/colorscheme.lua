-- [[ Colorscheme ]]
-- You can easily change to a different colorscheme.
-- Change the name of the colorscheme plugin below, and then
-- change the command under that to load whatever the name of that colorscheme is.
--
-- If you want to see what colorschemes are already installed, you can use `:Telescope colorscheme`.
-- vim.pack.add { 'https://github.com/folke/tokyonight.nvim' }
-- ---@diagnostic disable-next-line: missing-fields
-- require('tokyonight').setup {
--   styles = {
--     comments = { italic = false }, -- Disable italics in comments
--   },
--   -- Use the terminal's background instead of drawing an opaque one,
--   -- so Neovim inherits whatever transparency/color the terminal has set.
--   transparent = true,
-- }

-- Load the colorscheme here.
-- Like many other themes, this one has different styles, and you could load
-- any other, such as 'tokyonight-storm', 'tokyonight-moon', or 'tokyonight-day'.
-- vim.cmd.colorscheme 'tokyonight-night'
--
vim.pack.add({ "https://github.com/ember-theme/nvim" })
require("ember").setup({
  variant = "ember", -- "ember", "ember-soft", "ember-light", "ember-auto"
  -- styles = {
  --   comments  = { italic = true },
  --   keywords  = { bold = true },
  --   functions = {},
  --   types     = { bold = true },
  -- },
  transparent        = true, -- transparent editor background
  transparent_floats = false,   -- follows `transparent` by default; set explicitly to override
  on_colors     = nil, -- function(palette) - modify palette before theme builds
  on_highlights = function(highlights, theme)
    -- Match the Telescope prompt box to the same background as every other
    -- float instead of the theme's default (slightly different) shade.
    highlights.TelescopePromptNormal.bg = theme.ui.float_bg
    highlights.TelescopePromptBorder.bg = theme.ui.float_bg
    highlights.TelescopePromptTitle.bg = theme.ui.float_bg
  end,
})
vim.cmd.colorscheme("ember")

-- Belt-and-suspenders: clear background on the groups most likely to still
-- paint one over the terminal's, even with `transparent = true`.
-- NormalFloat is deliberately excluded so floating windows (hover, completion, etc.) keep their own background.
-- for _, group in ipairs { 'Normal', 'NormalNC', 'SignColumn', 'LineNr', 'EndOfBuffer' } do
--   vim.api.nvim_set_hl(0, group, { bg = 'none' })
-- end

-- vim: ts=2 sts=2 sw=2 et
