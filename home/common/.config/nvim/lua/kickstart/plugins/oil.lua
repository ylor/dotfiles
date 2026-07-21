-- Oil.nvim lets you edit a directory listing like a normal buffer (rename,
-- delete, create files by editing lines) instead of netrw's browser.
-- https://github.com/stevearc/oil.nvim

-- Disable netrw entirely so Oil is the only directory handler.
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

vim.pack.add { 'https://github.com/stevearc/oil.nvim' }

require('oil').setup {
  default_file_explorer = true,
  view_options = {
    show_hidden = true,
    -- Hide the '..' parent entry and .DS_Store, even with hidden files shown.
    is_always_hidden = function(name) return name == '..' or name == '.DS_Store' end,
  },
  keymaps = {
    -- Go up a directory, same as '-'.
    ['<BS>'] = 'actions.parent',
  },
}

-- Open the parent directory of the current file (Oil's usual convention).
vim.keymap.set('n', '-', '<Cmd>Oil<CR>', { desc = 'Open parent directory' })
