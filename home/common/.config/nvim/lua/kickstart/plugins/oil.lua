-- https://github.com/stevearc/oil.nvim

-- Disable netrw entirely so Oil is the only directory handler.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

local oil = require("oil")

vim.api.nvim_create_autocmd("User", {
	desc = "Open the Oil preview pane",
	pattern = "OilEnter",
	callback = function()
		if not vim.w.is_oil_win then
			vim.schedule(oil.open_preview)
		end
	end,
})

oil.setup({
	win_options = {
		number = false,
		relativenumber = false,
		statuscolumn = "",
	},
	view_options = {
		show_hidden = true,
		is_always_hidden = function(name)
			return name == ".." or name == ".DS_Store" or name == ".git"
		end,
	},
	keymaps = {
		["<BS>"] = "actions.parent",
		["<Esc>"] = "actions.close",
		["<C-d>"] = "actions.preview_scroll_down",
		["<C-u>"] = "actions.preview_scroll_up",
	},
})

vim.keymap.set("n", "-", oil.open, { desc = "Open parent directory" })
