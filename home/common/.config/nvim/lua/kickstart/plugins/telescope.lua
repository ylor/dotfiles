local function gh(repo) return 'https://github.com/' .. repo end

-- [[ Fuzzy Finder (files, lsp, etc) ]]
--
-- Telescope is a fuzzy finder that comes with a lot of different things that
-- it can fuzzy find! It's more than just a "file finder", it can search
-- many different aspects of Neovim, your workspace, LSP, and more!
--
-- There are lots of other alternative pickers (like snacks.picker, or fzf-lua)
-- so feel free to experiment and see what you like!
--
-- The easiest way to use Telescope, is to start by doing something like:
--  :Telescope help_tags
--
-- After running this command, a window will open up and you're able to
-- type in the prompt window. You'll see a list of `help_tags` options and
-- a corresponding preview of the help.
--
-- Two important keymaps to use while in Telescope are:
--  - Insert mode: <c-/>
--  - Normal mode: ?
--
-- This opens a window that shows you all of the keymaps for the current
-- Telescope picker. This is really useful to discover what Telescope can
-- do as well as how to actually do it!

---@type (string|vim.pack.Spec)[]
local telescope_plugins = {
  gh 'nvim-lua/plenary.nvim',
  gh 'nvim-telescope/telescope.nvim',
  gh 'nvim-telescope/telescope-ui-select.nvim',
  -- gh 'nvim-telescope/telescope-file-browser.nvim',
}
if vim.fn.executable 'make' == 1 then table.insert(telescope_plugins, gh 'nvim-telescope/telescope-fzf-native.nvim') end

-- NOTE: You can install multiple plugins at once
vim.pack.add(telescope_plugins)

-- See `:help telescope` and `:help telescope.setup()`
require('telescope').setup {
  -- You can put your default mappings / updates / etc. in here
  --  All the info you're looking for is in `:help telescope.setup()`
  --
  defaults = {
    -- Hide the "Find Files" / "Live Grep" / etc border titles on each window.
    -- `prompt_title`/`preview_title` are deliberately NOT set here: builtin
    -- pickers hardcode their own `prompt_title`, and `preview_title` never
    -- consults this table at all, so both are handled below instead via the
    -- `pickers.new` wrap. `results_title` is the one Telescope actually
    -- applies from here.
    results_title = false,
    -- `find_files`'s `hidden = true` below only skips fd/rg's default dotfile
    -- skip; it doesn't stop .git/ from being walked, so exclude it here.
    file_ignore_patterns = { '^%.git/' },
    -- mappings = {
    --   i = { ['<c-enter>'] = 'to_fuzzy_refine' },
    -- },
  },
  pickers = {
    find_files = {
      -- Show dotfiles too; .gitignore'd paths (e.g. .git/) are still excluded.
      hidden = true,
      -- With an empty prompt, entries display in whatever order the finder
      -- emits them; the sorter only kicks in once you actually type. When rg
      -- is available (Telescope's own first choice too), `--sort path` makes
      -- that empty-prompt order alphabetical instead of rg's traversal order.
      -- Leave unset otherwise so Telescope's own fd/find/where fallback runs.
      find_command = vim.fn.executable 'rg' == 1 and { 'rg', '--files', '--color', 'never', '--sort', 'path' } or nil,
    },
  },
  extensions = {
    ['ui-select'] = { require('telescope.themes').get_dropdown() },
    -- file_browser = {
    --   -- `grouped` sorts directories before files (both alphabetically);
    --   -- without it entries are left in raw scandir order.
    --   grouped = true,
    --   -- Telescope's default `sorting_strategy` is "descending", which fills
    --   -- results upward from the bottom of the window. "ascending" reads
    --   -- top-down like a normal file listing instead.
    --   sorting_strategy = 'ascending',
    --   -- Drop the mode/date/size columns telescope-file-browser shows by
    --   -- default; just icon + name.
    --   display_stat = false,
    --   -- Don't show a `..` entry; use `g` (normal) / `<C-g>` (insert) to go
    --   -- to the parent directory instead.
    --   hide_parent_dir = true,
    --   -- Once you type into the prompt, search recurses into subdirectories
    --   -- instead of only matching the current directory's entries. This is
    --   -- still filename-only; it does not search file contents.
    --   auto_depth = true,
    --   attach_mappings = function(prompt_bufnr, map)
    --     -- `<C-p>` swaps out to the regular (fd-backed, gitignore-aware)
    --     -- find_files picker, recursively rooted at whatever directory is
    --     -- currently open in the browser.
    --     map({ 'i', 'n' }, '<C-p>', function()
    --       local finder = require('telescope.actions.state').get_current_picker(prompt_bufnr).finder
    --       local cwd = finder.files and finder.path or finder.cwd
    --       require('telescope.actions').close(prompt_bufnr)
    --       require('telescope.builtin').find_files { cwd = cwd }
    --     end)
    --     return true
    --   end,
    -- },
  },
}

-- Most builtin pickers (find_files, live_grep, etc.) hardcode their own
-- prompt_title, which Telescope always prefers over `defaults.prompt_title`
-- above (see `:h telescope.defaults.prompt_title`). preview_title is set
-- dynamically per-previewer and never consults `defaults` at all. Wrap
-- pickers.new so both are forced off too, while a title passed explicitly at
-- the call site (like the `<leader>s/` mapping below) still wins.
local pickers = require 'telescope.pickers'
if type(pickers.new) == 'function' then
  local pickers_new = pickers.new
  pickers.new = function(opts, defaults)
    defaults = vim.tbl_extend('force', defaults or {}, { prompt_title = false, preview_title = false })
    return pickers_new(opts, defaults)
  end
end

-- Enable Telescope extensions if they are installed
pcall(require('telescope').load_extension, 'fzf')
pcall(require('telescope').load_extension, 'ui-select')
-- pcall(require('telescope').load_extension, 'file_browser')

-- See `:help telescope.builtin`
local builtin = require 'telescope.builtin'
vim.keymap.set('n', '<leader>sh', builtin.help_tags, { desc = '[S]earch [H]elp' })
vim.keymap.set('n', '<leader>sk', builtin.keymaps, { desc = '[S]earch [K]eymaps' })
vim.keymap.set('n', '<leader>sf', builtin.find_files, { desc = '[S]earch [F]iles' })
vim.keymap.set('n', '<leader>ss', builtin.builtin, { desc = '[S]earch [S]elect Telescope' })
vim.keymap.set({ 'n', 'v' }, '<leader>sw', builtin.grep_string, { desc = '[S]earch current [W]ord' })
vim.keymap.set('n', '<leader>sg', builtin.live_grep, { desc = '[S]earch by [G]rep' })
vim.keymap.set('n', '<leader>sd', builtin.diagnostics, { desc = '[S]earch [D]iagnostics' })
vim.keymap.set('n', '<leader>sr', builtin.resume, { desc = '[S]earch [R]esume' })
vim.keymap.set('n', '<leader>s.', builtin.oldfiles, { desc = '[S]earch Recent Files ("." for repeat)' })
vim.keymap.set('n', '<leader>sc', builtin.commands, { desc = '[S]earch [C]ommands' })
vim.keymap.set('n', '<leader><leader>', builtin.buffers, { desc = '[ ] Find existing buffers' })

-- Add Telescope-based LSP pickers when an LSP attaches to a buffer.
-- If you later switch picker plugins, this is where to update these mappings.
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('telescope-lsp-attach', { clear = true }),
  callback = function(event)
    local buf = event.buf

    -- Find references for the word under your cursor.
    vim.keymap.set('n', 'grr', builtin.lsp_references, { buffer = buf, desc = '[G]oto [R]eferences' })

    -- Jump to the implementation of the word under your cursor.
    -- Useful when your language has ways of declaring types without an actual implementation.
    vim.keymap.set('n', 'gri', builtin.lsp_implementations, { buffer = buf, desc = '[G]oto [I]mplementation' })

    -- Jump to the definition of the word under your cursor.
    -- This is where a variable was first declared, or where a function is defined, etc.
    -- To jump back, press <C-t>.
    vim.keymap.set('n', 'grd', builtin.lsp_definitions, { buffer = buf, desc = '[G]oto [D]efinition' })

    -- Fuzzy find all the symbols in your current document.
    -- Symbols are things like variables, functions, types, etc.
    vim.keymap.set('n', 'gO', builtin.lsp_document_symbols, { buffer = buf, desc = 'Open Document Symbols' })

    -- Fuzzy find all the symbols in your current workspace.
    -- Similar to document symbols, except searches over your entire project.
    vim.keymap.set('n', 'gW', builtin.lsp_dynamic_workspace_symbols, { buffer = buf, desc = 'Open Workspace Symbols' })

    -- Jump to the type of the word under your cursor.
    -- Useful when you're not sure what type a variable is and you want to see
    -- the definition of its *type*, not where it was *defined*.
    vim.keymap.set('n', 'grt', builtin.lsp_type_definitions, { buffer = buf, desc = '[G]oto [T]ype Definition' })
  end,
})

-- Override default behavior and theme when searching
vim.keymap.set('n', '<leader>/', function()
  -- You can pass additional configuration to Telescope to change the theme, layout, etc.
  builtin.current_buffer_fuzzy_find(require('telescope.themes').get_dropdown {
    winblend = 10,
    previewer = false,
  })
end, { desc = '[/] Fuzzily search in current buffer' })

-- It's also possible to pass additional configuration options.
--  See `:help telescope.builtin.live_grep()` for information about particular keys
vim.keymap.set(
  'n',
  '<leader>s/',
  function()
    builtin.live_grep {
      grep_open_files = true,
      prompt_title = 'Live Grep in Open Files',
    }
  end,
  { desc = '[S]earch [/] in Open Files' }
)

-- Shortcut for searching your Neovim configuration files
vim.keymap.set('n', '<leader>sn', function() builtin.find_files { cwd = vim.fn.stdpath 'config', follow = true } end, { desc = '[S]earch [N]eovim files' })

-- Open the file browser at the current buffer's directory (or cwd for a
-- buffer with no file, e.g. right after `nvim .`).
-- vim.keymap.set(
--   'n',
--   '<leader>e',
--   function() require('telescope').extensions.file_browser.file_browser { path = '%:p:h', select_buffer = true } end,
--   { desc = 'Open file [E]xplorer' }
-- )

-- When Neovim is started with a directory argument (e.g. `nvim .`), show
-- Telescope's find_files picker rooted there instead of netrw's browser.
vim.g.loaded_netrwPlugin = 1
vim.api.nvim_create_autocmd('VimEnter', {
  group = vim.api.nvim_create_augroup('telescope-open-dir', { clear = true }),
  callback = function(data)
    local stat = vim.uv.fs_stat(data.file)
    if not (stat and stat.type == 'directory') then return end

    vim.bo.bufhidden = 'wipe'
    vim.cmd.cd(data.file)
    builtin.find_files { cwd = data.file }
  end,
})

-- vim: ts=2 sts=2 sw=2 et
