-- https://github.com/stevearc/oil.nvim

-- Disable netrw entirely so Oil is the only directory handler.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

local oil = require("oil")

oil.setup({
	default_file_explorer = true,
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
		-- ["<Esc>"] = "actions.close",
		["<C-d>"] = "actions.preview_scroll_down",
		["<C-u>"] = "actions.preview_scroll_up",
	},
	skip_confirm_for_simple_edits = false,
	watch_for_changes = true,
})

vim.keymap.set("n", "-", function()
	oil.open(nil, { preview = {} })
end, { desc = "Open parent directory with preview" })
