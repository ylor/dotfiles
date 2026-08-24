-- [[ Colorscheme ]]
-- Read the active terminal palette through OSC and use it as true-color values.
-- vim.opt.termguicolors = true
-- vim.pack.add({ "https://github.com/GooseRooster/osc-colors.nvim" })
--
-- require("osc-colors").setup({
-- 	capabilities = {
-- 		truecolor = true,
-- 		terminal_colors = true,
-- 	},
-- 	ui = {
-- 		transparent = true,
-- 	},
-- 	highlights = {
-- 		overrides = function(palette)
-- 			return {
-- 				ColorColumn = { link = "CursorLine" },
-- 				StatusLine = { fg = palette.base06, bg = "none", bold = true },
-- 				StatusLineNC = { fg = palette.base03, bg = "none" },
-- 				EndOfBuffer = { bg = "none" },
-- 			}
-- 		end,
-- 	},
-- })

-- vim.opt.termguicolors = true
vim.pack.add({ "https://github.com/tahayvr/matteblack.nvim" })
vim.cmd.colorscheme("matteblack")

for _, group in ipairs({ "Normal", "NormalNC" }) do
	vim.api.nvim_set_hl(0, group, { fg = "none", bg = "none" })
end

-- vim: ts=2 sts=2 sw=2 et
