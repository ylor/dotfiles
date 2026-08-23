-- [[ Colorscheme ]]
-- Use ANSI colors from the active terminal palette.
vim.opt.termguicolors = false

vim.pack.add({ "https://github.com/bjarneo/pixel.nvim" })
require("pixel").setup({
	disable_italics = false,
})
vim.cmd.colorscheme("pixel")

vim.api.nvim_set_hl(0, "StatusLine", {
	ctermfg = 7,
	bg = "none",
	bold = true,
})
vim.api.nvim_set_hl(0, "StatusLineNC", {
	ctermfg = 8,
	bg = "none",
})

for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }) do
	vim.api.nvim_set_hl(0, group, { bg = "none" })
end

-- Previous colorscheme configuration.
-- vim.pack.add({ "https://github.com/kungfusheep/mfd.nvim" })
-- require("mfd").setup({ accessibility_contrast = 4 })
-- vim.cmd.colorscheme("mfd-nerv")
-- vim.api.nvim_set_hl(0, "ColorColumn", { link = "CursorLine" })
--
-- for _, group in ipairs({ "Normal", "NormalNC", "SignColumn", "LineNr", "EndOfBuffer" }) do
-- 	vim.api.nvim_set_hl(0, group, { bg = "none" })
-- end
--
-- vim.api.nvim_set_hl(0, "TelescopeNormal", { link = "Normal" })
-- vim.api.nvim_set_hl(0, "TelescopeBorder", { link = "FloaBorder" })
-- vim.api.nvim_set_hl(0, "TelescopePromptNormal", { link = "Normal" })
-- vim.api.nvim_set_hl(0, "TelescopePromptBorder", { link = "Normal" })

-- vim: ts=2 sts=2 sw=2 et
