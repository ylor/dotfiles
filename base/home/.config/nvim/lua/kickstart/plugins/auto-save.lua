-- Autosave: write the current buffer shortly after you stop typing, and
-- immediately on leaving it/losing focus. https://github.com/okuuva/auto-save.nvim
vim.pack.add { 'https://github.com/okuuva/auto-save.nvim' }

require('auto-save').setup {
  -- Non-modifiable buffers (LSP hover popups, etc.) are already excluded by
  -- the plugin itself; also skip readonly ones (e.g. `view`-opened files).
  condition = function(buf) return not vim.bo[buf].readonly end,
}

-- vim: ts=2 sts=2 sw=2 et
