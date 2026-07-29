-- Enable faster startup by caching compiled Lua modules
vim.loader.enable()

-- Set <space> as the leader key
-- See `:help mapleader`
--  NOTE: Must happen before plugins are loaded (otherwise wrong leader will be used)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if you have a Nerd Font installed and selected in the terminal
-- vim.g.have_nerd_font = true

-- [[ Setting options ]]
--  See `:help vim.o`
-- NOTE: You can change these options as you wish!
--  For more options, you can see `:help option-list`

-- Make line numbers default
vim.opt.number = true
-- You can also add relative line numbers, to help with jumping.
--  Experiment for yourself to see if you like it!
vim.opt.relativenumber = true
vim.o.statuscolumn = "%{v:relnum == 0 ? v:lnum : v:relnum + 1}%="

-- Enable mouse mode, can be useful for resizing splits for example!
vim.opt.mouse = "a"

-- Don't show the mode, since it's already in the status line
vim.opt.showmode = false

-- Show the current buffer in the terminal title. Before a file is opened
-- (e.g. `nvim some/dir` or `nvim some/dir/file.txt`, which start with that
-- file/dir's buffer not yet focused), there's no normal-buffer name yet, so
-- fall back to the tail of the file/dir passed on the command line -- not
-- `getcwd()`, which stays at the shell's cwd and never follows a directory
-- argument. `:h` on a directory (whose `:p` form has a trailing slash) just
-- strips that slash rather than ascending a level, so `:p:h:t` alone -- with
-- no `isdirectory` branch -- gives the right tail for a directory or a file.
-- `nvim` with no argument at all has nothing to fall back to, so
-- `startup_fallback` stays empty and `NvimTitleName` shows a bare "nvim".
local startup_fallback = vim.fn.argc() > 0 and (" [" .. vim.fn.fnamemodify(vim.fn.argv(0), ":p:h:t") .. "]") or ""

-- The name of the current tabpage's normal (buftype == "") buffer, checking
-- the focused window first and falling back to the other windows in the
-- tabpage. Floating scratch windows -- e.g. Telescope's prompt/results/
-- preview, which sit over the tabpage rather than splitting it -- have a
-- non-"" buftype, so a Telescope window being focused falls through to the
-- normal file window underneath instead of returning its own (blank) name.
-- Computed fresh on every call rather than cached, so there's no listener to
-- keep in sync with buffer/window changes.
local function focused_file_name()
	local function normal_buf_name(win)
		local buf = vim.api.nvim_win_get_buf(win)
		if vim.bo[buf].buftype ~= "" then
			return nil
		end
		local name = vim.api.nvim_buf_get_name(buf)
		return name ~= "" and vim.fn.fnamemodify(name, ":t") or nil
	end

	local name = normal_buf_name(vim.api.nvim_get_current_win())
	if name then
		return name
	end
	for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
		name = normal_buf_name(win)
		if name then
			return name
		end
	end
	return nil
end

-- Dash-prefix a focused file name (e.g. `nvim - init.lua`); otherwise fall
-- back to the bracketed startup arg, or nothing for a bare `nvim`. The
-- leading space lives in here (not in `titlestring` below) so a bare `nvim`
-- renders as exactly "nvim" with no trailing space -- a static space in
-- `titlestring` would still be there when this returns "", and terminals
-- that center tab titles visibly shift the text for an invisible trailing
-- character.
function _G.NvimTitleName()
	local name = focused_file_name()
	return name and " - " .. name or startup_fallback
end

vim.opt.title = true
vim.opt.titlestring = "nvim%{v:lua.NvimTitleName()}"

-- Don't show Neovim's built-in intro screen on startup.
vim.opt.shortmess:append("I")

-- Hide the command line when it isn't in use, showing it only while a
-- command/search is being entered or a message needs to be displayed.
vim.opt.cmdheight = 0

-- Keep floating windows fully opaque.
vim.opt.winblend = 0

-- Command-line/search completion (live popup as you type, <Tab>/<S-Tab> to
-- cycle matches, <Up>/<Down> for history) is handled by blink.cmp's cmdline
-- mode -- see `cmdline` in lua/kickstart/plugins/blink-cmp.lua.

-- Sync clipboard between OS and Neovim.
--  Schedule the setting after `UiEnter` because it can increase startup-time.
--  Remove this option if you want your OS clipboard to remain independent.
--  See `:help 'clipboard'`
vim.schedule(function()
	vim.opt.clipboard = "unnamedplus"
end)

-- Wrap long lines at word boundaries and indent wrapped lines to match the
-- start of the line, so wrapped text stays visually aligned.
vim.opt.wrap = true
vim.opt.linebreak = true
vim.opt.breakindent = true

-- Mark column 100 as a visual guide.
vim.opt.colorcolumn = "100"

-- Enable undo/redo changes even after closing and reopening a file
-- vim.cmd("packadd nvim.undotree")
-- vim.keymap.set("n", "<leader>u", require("undotree").open)
vim.opt.undofile = true

-- Case-insensitive searching UNLESS \C or one or more capital letters in the search term
vim.opt.ignorecase = true
vim.opt.smartcase = true

-- Keep signcolumn on by default
vim.opt.signcolumn = "yes"

-- Decrease update time
vim.opt.updatetime = 250

-- Decrease mapped sequence wait time
-- vim.opt.timeoutlen = 500

-- Configure how new splits should be opened
vim.opt.splitright = true
vim.opt.splitbelow = true

-- Sets how neovim will display certain whitespace characters in the editor.
--  See `:help 'list'`
--  and `:help 'listchars'`
--
--  Notice listchars is set using `vim.opt` instead of `vim.o`.
--  It is very similar to `vim.o` but offers an interface for conveniently interacting with tables.
--   See `:help lua-options`
--   and `:help lua-guide-options`
vim.opt.list = true
vim.opt.listchars = { tab = "» ", trail = "·", nbsp = "␣" }

-- Preview substitutions live, as you type!
vim.opt.inccommand = "split"

-- Show which line your cursor is on
vim.opt.cursorline = true

-- Minimal number of screen lines to keep above and below the cursor.
vim.opt.scrolloff = 10

-- if performing an operation that would fail due to unsaved changes in the buffer (like `:q`),
-- instead raise a dialog asking if you wish to save the current file(s)
-- See `:help 'confirm'`
vim.opt.confirm = true

-- Reload a buffer automatically when the underlying file changed on disk,
-- as long as it hasn't been modified in the buffer itself.
-- See `:help 'autoread'`
vim.opt.autoread = true

-- Remove the "How-to disable mouse" entry (and its separator) that Nvim adds
-- to the default right-click popup menu. See `:h vim_diff.txt` for this exact
-- recipe.
pcall(
	vim.cmd,
	[[
  aunmenu PopUp.How-to\ disable\ mouse
  aunmenu PopUp.-2-
]]
)

-- vim: ts=2 sts=2 sw=2 et
