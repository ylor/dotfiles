-- https://github.com/stevearc/oil.nvim

-- Disable netrw entirely so Oil is the only directory handler.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add({ "https://github.com/stevearc/oil.nvim" })

local oil = require("oil")

local function telescope(picker)
	return function()
		require("telescope.builtin")[picker]({ cwd = oil.get_current_dir() })
	end
end

-- Oil's default directory handler does not accept the `preview` option used by
-- the mapping below. Register this before setup so it catches the initial Oil
-- buffer when a directory was supplied on the command line (for example,
-- `nvim .`).
local startup_path = vim.fn.argc() > 0 and vim.fn.argv(0) or nil
if startup_path and vim.fn.isdirectory(startup_path) == 1 then
	vim.api.nvim_create_autocmd("User", {
		pattern = "OilEnter",
		once = true,
		callback = function()
			vim.schedule(oil.open_preview)
		end,
	})
end

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
		["f"] = telescope("find_files"),
		["g"] = telescope("live_grep"),
	},
	skip_confirm_for_simple_edits = false,
	watch_for_changes = true,
})

vim.keymap.set("n", "-", function()
	oil.open(nil, { preview = {} })
end, { desc = "Open parent directory with preview" })
