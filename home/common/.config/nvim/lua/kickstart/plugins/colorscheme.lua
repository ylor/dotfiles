-- [[ Colorscheme ]]
-- You can easily change to a different colorscheme.
-- Change the name of the colorscheme plugin below, and then
-- change the command under that to load whatever the name of that colorscheme is.
vim.pack.add({ "https://github.com/kungfusheep/mfd.nvim" })
require("mfd").setup({ accessibility_contrast = 4 })
vim.cmd.colorscheme("mfd-nerv")
vim.api.nvim_set_hl(0, "ColorColumn", { link = "CursorLine" })

-- Use the terminal's background for regular editor windows. NormalFloat is
-- deliberately excluded so hover, completion, and other floats stay readable.
for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end

-- Keep Telescope's windows consistent with other floating windows instead of
-- using mfd-amber's darker selection color as their background.
vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloaBorder" })
vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "Normal" })
vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "Normal" })

-- vim: ts=2 sts=2 sw=2 et
