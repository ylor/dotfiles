-- [[ mini.nvim ]]
--  A collection of various small independent plugins/modules
vim.pack.add({ "https://github.com/nvim-mini/mini.nvim" })

-- Sane option/mapping/autocommand defaults that are only applied if not
-- already set elsewhere, so this is safe to layer on top of options.lua,
-- keymaps.lua, and autocmds.lua.
--  - mappings.windows replaces the hand-rolled <C-hjkl> window-nav mappings
--    in keymaps.lua (and adds <C-arrows> resize on top).
--  - autocommands.basic replaces the hand-rolled yank-highlight autocmd in
--    keymaps.lua.
require("mini.basics").setup({
	options = { basic = true, extra_ui = true },
	mappings = { basic = true, windows = true },
	autocommands = { basic = true },
})

-- Load the icons module for file-type icons in various plugins (Oil,
-- Telescope, ...). Falls back to plain ASCII icons without a Nerd Font
-- instead of glyphs that would render as tofu boxes.
require("mini.icons").setup({ style = vim.g.have_nerd_font and "glyph" or "ascii" })
-- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim, oil.nvim)
MiniIcons.mock_nvim_web_devicons()

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require("mini.ai").setup({
	-- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
	mappings = {
		around_next = "aa",
		inside_next = "ii",
	},
	n_lines = 500,
})

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require("mini.surround").setup()

-- Auto-close/skip-over paired brackets and quotes.
-- Replaces kickstart.plugins.autopairs (nvim-autopairs) for now.
require("mini.pairs").setup()

-- Command-line tweaks: debounced autocomplete popup, as-you-type
-- autocorrection of commands/options, and a floating autopeek window that
-- previews the target lines of a `:range` (e.g. while typing `:10,20d`).
-- require("mini.cmdline").setup()

-- File explorer: mini.files was considered here but oil.nvim
-- (kickstart.plugins.oil) is used instead.

-- Inline hex color highlighting: paints `#rgb`/`#rgba`/`#rrggbb`/`#rrggbbaa`
-- literals with the color they name, using the color itself as background.
-- Not `gen_highlighter.hex_color()` (mini.hipatterns' own built-in): that
-- only matches full 6-digit hex, because `nvim_set_hl` itself rejects
-- 3-digit CSS shorthand like `#fff` -- this expands shorthand to 6 digits
-- (and drops the alpha channel of 4/8-digit forms) before handing off.
-- Not `vim.lsp.document_color` either: that needs an LSP server that
-- implements `textDocument/documentColor` (e.g. cssls), and none is
-- configured here.
local hipatterns = require("mini.hipatterns")
local hex_valid_len = { [3] = true, [4] = true, [6] = true, [8] = true }
local hex_short_len = { [3] = true, [4] = true }
-- Filetypes where a leading `#` is far more likely to be a reference (a
-- git-style short SHA, a markdown/issue anchor) than a color literal.
local hex_excluded_filetypes = {
	markdown = true,
	gitcommit = true,
	gitrebase = true,
	help = true,
}
hipatterns.setup({
	highlighters = {
		hex_color = {
			pattern = function(buf_id)
				if hex_excluded_filetypes[vim.bo[buf_id].filetype] then
					return nil
				end
				return "#%x+"
			end,
			group = function(_, _, data)
				local hex = data.full_match:sub(2):lower()
				if not hex_valid_len[#hex] then
					return nil
				end
				if hex_short_len[#hex] then
					hex = hex:sub(1, 3):gsub(".", "%0%0")
				end
				-- Oklab-based contrast pick + colorscheme-reset cache handled by
				-- mini.hipatterns itself.
				return hipatterns.compute_hex_color_group("#" .. hex:sub(1, 6), "bg")
			end,
		},
	},
})

-- Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require("mini.statusline")
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function()
	return "%2l:%-2v"
end

--[[
-- Start screen shown when opening Neovim with no file argument.
--  Replaces the built-in `netrw`-adjacent blank splash with a small
--  greeting, recently opened files, and a few common actions.
local starter = require("mini.starter")
starter.setup({
	-- Run an item's action as soon as its typed query uniquely matches it,
	-- instead of requiring <CR>. All current items have distinct first
	-- letters, so this effectively makes each one a single-keypress action.
	evaluate_single = true,
	-- Same logo + version line as Neovim's own `:intro` screen (see
	-- `intro_message()` in src/nvim/version.c).
	header = function()
		local v = vim.version()
		return table.concat({
			"│ ╲ ││",
			"││╲╲││",
			"││ ╲ │",
			"",
			("NVIM v%d.%d.%d"):format(v.major, v.minor, v.patch),
		}, "\n")
	end,
	-- Fixed menu, one item per letter (works with `evaluate_single` above
	-- for single-keypress selection). No section heading shown above them.
	items = {
		{ name = "New", action = "enew", section = "" },
		{ name = "Files", action = "Telescope find_files", section = "" },
		{ name = "Recent", action = "Telescope oldfiles", section = "" },
		{ name = "Grep", action = "Telescope live_grep", section = "" },
		{
			name = "Config",
			action = "Telescope find_files cwd=" .. vim.fn.stdpath("config") .. " follow=true",
			section = "",
		},
		{ name = "Help", action = "Telescope help_tags", section = "" },
		{ name = "Quit", action = "qall", section = "" },
	},
	-- Hide the default footer with query/keymap usage instructions.
	footer = "",
	content_hooks = {
		-- An empty `section = ''` still inserts a blank section-heading line;
		-- drop it so items sit directly below the normal header gap.
		function(content)
			return vim.tbl_filter(function(line)
				return not (line[1].type == "section" and line[1].string == "")
			end, content)
		end,
		starter.gen_hook.adding_bullet(),
		starter.gen_hook.aligning("center", "center"),
	},
})

-- mini.starter's built-in navigation is <Up>/<Down>, <C-p>/<C-n>, and
-- <M-j>/<M-k> -- plain j/k/l are left free for typing a query (letters
-- filter items by name). None of the items above start with j or k, so
-- add j/k/l as extra buffer-local navigation + select keys on top.
vim.api.nvim_create_autocmd("User", {
	pattern = "MiniStarterOpened",
	callback = function(args)
		vim.keymap.set("n", "j", "<Cmd>lua MiniStarter.update_current_item('next')<CR>", { buffer = args.buf })
		vim.keymap.set("n", "k", "<Cmd>lua MiniStarter.update_current_item('prev')<CR>", { buffer = args.buf })
		vim.keymap.set("n", "l", "<Cmd>lua MiniStarter.eval_current_item()<CR>", { buffer = args.buf })
	end,
})

-- mini.starter only autoopens when Neovim is given no arguments at all (see
-- its `autoopen` check), so `nvim some_dir` falls through instead of
-- showing it. Since Oil no longer claims directory buffers either (see
-- kickstart.plugins.oil), that would otherwise sit there as an empty,
-- unmanaged buffer. Redirect to the start screen in that case, then
-- straight on into Telescope's file finder (`<Esc>` from it lands back on
-- the starter buffer underneath).
--
-- Only the window that's current at VimEnter gets this treatment; any other
-- window that was also given a directory arg (e.g. `nvim -o dir1 dir2`)
-- keeps its raw directory buffer until it's focused, at which point the
-- BufEnter autocmd in kickstart.plugins.oil picks it up. Running the
-- starter+Telescope flow more than once at startup doesn't make sense.
vim.api.nvim_create_autocmd("VimEnter", {
	once = true,
	callback = function()
		local buf = vim.api.nvim_get_current_buf()
		local name = vim.api.nvim_buf_get_name(buf)
		if name ~= "" and vim.fn.isdirectory(name) == 1 then
			-- Window-local cd (not global) so Telescope (and the starter items
			-- below: Files, Recent, Grep) search the directory that was passed
			-- on the command line, without changing cwd for any other window/tab.
			vim.cmd.lcd(name)
			starter.open()
			vim.api.nvim_buf_delete(buf, { force = true })
			vim.schedule(function()
				vim.cmd.Telescope("find_files")
			end)
		end
	end,
})
--]]

-- ... and there is more!
--  Check out: https://github.com/nvim-mini/mini.nvim

-- vim: ts=2 sts=2 sw=2 et
