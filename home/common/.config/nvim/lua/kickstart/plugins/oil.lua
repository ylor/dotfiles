-- Oil.nvim lets you edit a directory listing like a normal buffer (rename,
-- delete, create files by editing lines) instead of netrw's browser.
-- https://github.com/stevearc/oil.nvim

-- Disable netrw entirely so Oil is the only directory handler.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup {
  -- Don't let Oil silently become the buffer for `nvim .` / `:e some_dir` /
  -- etc; it should open deliberately, as a floating window, either via the
  -- '-' keybind or the BufEnter autocmd below (which is what actually
  -- handles directory buffers now that this is off).
  default_file_explorer = false,
  view_options = {
    show_hidden = true,
    -- Hide the '..' parent entry and .DS_Store, even with hidden files shown.
    is_always_hidden = function(name) return name == '..' or name == '.DS_Store' end,
  },
  keymaps = {
    -- Go up a directory, same as '-'.
    ['<BS>'] = 'actions.parent',
    -- Dismiss the floating window.
    ['<Esc>'] = 'actions.close',
    -- Scroll the preview pane without leaving the oil pane (the preview
    -- window is unfocusable, so normal window navigation can't reach it).
    ['<C-d>'] = 'actions.preview_scroll_down',
    ['<C-u>'] = 'actions.preview_scroll_up',
  },
  float = {
    -- Also doubles as the gap between the oil pane and its preview pane, so
    -- keep it small or the two panes read as disconnected boxes.
    padding = 1,
    max_width = 0.8,
    max_height = 0.8,
    border = 'rounded',
  },
}

-- Floating window with the file/directory preview split shown immediately.
local function open_float(path) require('oil').open_float(path, { preview = {} }) end

-- Open the parent directory of the current file (Oil's usual convention).
vim.keymap.set('n', '-', function() open_float(nil) end, { desc = 'Open parent directory' })

-- With `default_file_explorer = false` and netrw disabled above, nothing
-- else claims directory buffers opened after startup (`:e some_dir`, `gf`
-- onto a directory, switching into a window that still has one from
-- startup, ...). Redirect any of those into the floating explorer instead
-- of leaving a bare, unmanaged buffer. (The very first directory buffer at
-- startup is handled separately, before VimEnter, by
-- kickstart.plugins.mini's starter+Telescope redirect.)
vim.api.nvim_create_autocmd('BufEnter', {
  desc = 'Redirect directory buffers to the Oil floating explorer',
  callback = function(args)
    if vim.v.vim_did_enter == 0 then return end
    -- Special buffer types (terminal, quickfix, help, nofile, ...) can never
    -- name a real directory, so this skips the isdirectory() filesystem stat
    -- for them; regular file buffers also have buftype == '', so they still
    -- pay for the stat on every BufEnter, but it's cheap enough not to cache.
    if vim.bo[args.buf].buftype ~= '' then return end
    local name = vim.api.nvim_buf_get_name(args.buf)
    if vim.fn.isdirectory(name) == 0 then return end
    open_float(name)
    vim.api.nvim_buf_delete(args.buf, { force = true })
  end,
})

-- Oil's file preview is a synthetic scratch buffer (buftype=nofile), with a
-- brand new one swapped in on every cursor move. mini.hipatterns' own
-- auto-enable only ever fires for buftype=='' buffers (see its `BufEnter`
-- handler in mini/hipatterns.lua), so it silently never turns on there.
-- Enable it explicitly whenever a buffer lands in Oil's preview window.
vim.api.nvim_create_autocmd('BufWinEnter', {
  desc = 'Enable mini.hipatterns in the Oil preview window',
  callback = function(args)
    if vim.w.oil_preview then require('mini.hipatterns').enable(args.buf) end
  end,
})
