-- [[ User Commands ]]
--  See `:help nvim_create_user_command()`

-- Reload the Neovim configuration without restarting. Clears every Lua
-- module this config owns (top-level files plus anything under the
-- `kickstart.*` / `custom.*` namespaces) so edits to colorscheme, plugin
-- setup, keymaps, etc. take effect, then re-sources init.lua.
local function reload_config()
  local own_modules = { options = true, keymaps = true, autocmds = true, pack = true, plugins = true, commands = true }
  for name, _ in pairs(package.loaded) do
    if own_modules[name] or name:match '^kickstart%.' or name:match '^custom%.' then
      package.loaded[name] = nil
    end
  end
  vim.cmd 'source $MYVIMRC'
  vim.notify('Config reloaded', vim.log.levels.INFO)
end

vim.api.nvim_create_user_command('ReloadConfig', reload_config, { desc = 'Reload the Neovim configuration' })
vim.keymap.set('n', '<leader>rc', reload_config, { desc = '[R]eload [C]onfig' })

-- vim: ts=2 sts=2 sw=2 et
