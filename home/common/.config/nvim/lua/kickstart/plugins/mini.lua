-- [[ mini.nvim ]]
--  A collection of various small independent plugins/modules
vim.pack.add { 'https://github.com/nvim-mini/mini.nvim' }

-- If a nerd font is available, load the icons module for pretty icons in various plugins.
if vim.g.have_nerd_font then
  require('mini.icons').setup()
  -- Used for backwards compatibility with plugins that require `nvim-web-devicons` (e.g. telescope.nvim)
  MiniIcons.mock_nvim_web_devicons()
end

-- Better Around/Inside textobjects
--
-- Examples:
--  - va)  - [V]isually select [A]round [)]paren
--  - yiiq - [Y]ank [I]nside [I]+1 [Q]uote
--  - ci'  - [C]hange [I]nside [']quote
require('mini.ai').setup {
  -- NOTE: Avoid conflicts with the built-in incremental selection mappings on Neovim>=0.12 (see `:help treesitter-incremental-selection`)
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

-- Add/delete/replace surroundings (brackets, quotes, etc.)
--
-- - saiw) - [S]urround [A]dd [I]nner [W]ord [)]Paren
-- - sd'   - [S]urround [D]elete [']quotes
-- - sr)'  - [S]urround [R]eplace [)] [']
require('mini.surround').setup()

-- Simple and easy statusline.
--  You could remove this setup call if you don't like it,
--  and try some other statusline plugin
local statusline = require 'mini.statusline'
-- Set `use_icons` to true if you have a Nerd Font
statusline.setup { use_icons = vim.g.have_nerd_font }

-- You can configure sections in the statusline by overriding their
-- default behavior. For example, here we set the section for
-- cursor location to LINE:COLUMN
---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end

-- Start screen shown when opening Neovim with no file argument.
--  Replaces the built-in `netrw`-adjacent blank splash with a small
--  greeting, recently opened files, and a few common actions.
local starter = require 'mini.starter'
starter.setup {
  -- Run an item's action as soon as its typed query uniquely matches it,
  -- instead of requiring <CR>. All current items have distinct first
  -- letters, so this effectively makes each one a single-keypress action.
  evaluate_single = true,
  -- Same logo + version line as Neovim's own `:intro` screen (see
  -- `intro_message()` in src/nvim/version.c).
  header = function()
    local v = vim.version()
    return table.concat({
      '│ ╲ ││',
      '││╲╲││',
      '││ ╲ │',
      '',
      ('NVIM v%d.%d.%d'):format(v.major, v.minor, v.patch),
    }, '\n')
  end,
  -- Fixed menu, one item per letter (works with `evaluate_single` above
  -- for single-keypress selection). No section heading shown above them.
  items = {
    { name = 'New', action = 'enew', section = '' },
    { name = 'Files', action = 'Telescope find_files', section = '' },
    { name = 'Recent', action = 'Telescope oldfiles', section = '' },
    { name = 'Grep', action = 'Telescope live_grep', section = '' },
    { name = 'Config', action = 'Telescope find_files cwd=' .. vim.fn.stdpath 'config' .. ' follow=true', section = '' },
    { name = 'Help', action = 'Telescope help_tags', section = '' },
    { name = 'Quit', action = 'qall', section = '' },
  },
  -- Hide the default footer with query/keymap usage instructions.
  footer = '',
  content_hooks = {
    -- An empty `section = ''` still inserts a blank section-heading line;
    -- drop it so items sit directly below the normal header gap.
    function(content)
      return vim.tbl_filter(function(line) return not (line[1].type == 'section' and line[1].string == '') end, content)
    end,
    starter.gen_hook.adding_bullet(),
    starter.gen_hook.aligning('center', 'center'),
  },
}

-- ... and there is more!
--  Check out: https://github.com/nvim-mini/mini.nvim

-- vim: ts=2 sts=2 sw=2 et
