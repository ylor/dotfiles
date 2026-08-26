-- [[ Colorscheme ]]
vim.opt.termguicolors = true
vim.opt.background = "dark"
vim.pack.add({ "https://github.com/ronisbr/nano-theme.nvim" })

local amber = require("nano-theme.colors.amber")
local build_colors = require("nano-theme.colors.utils").build_colors

rawset(amber, "dark", function()
	return build_colors({
		nano_foreground_color = "#d97706", -- amber-600
		nano_background_color = "#0c0a09", -- taupe-950
		nano_highlight_color = "#1d1816", -- taupe-900
		nano_subtle_color = "#2b2422", -- taupe-800
		nano_veryfaded_color = "#451a03", -- amber-950
		nano_faded_color = "#92400e", -- amber-800
		nano_salient_color = "#f59e0b", -- amber-500
		nano_strong_color = "#d97706", -- amber-600
		nano_popout_color = "#ea580c", -- orange-600
		nano_critical_color = "#ef4444", -- red-500

		ansi = {
			black = "#0c0a09", -- taupe-950
			red = "#dc2626", -- red-600
			green = "#059669", -- emerald-600
			yellow = "#f59e0b", -- amber-500
			blue = "#2563eb", -- blue-600
			magenta = "#d97706", -- amber-600
			cyan = "#0891b2", -- cyan-600
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

-- vim: ts=2 sts=2 sw=2 et
