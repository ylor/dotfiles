-- [[ Autoreload ]]
--  See `:help autocommand`
--  (Autosave is handled by kickstart.plugins.auto-save.)

local group = vim.api.nvim_create_augroup('kickstart-autoreload', { clear = true })

-- Autoreload: pick up changes made to a file on disk outside of Neovim.
-- `checktime` triggers Neovim's own reload logic (which itself refuses to
-- clobber unsaved changes in the buffer), we just need to call it at the
-- right moments since Neovim doesn't poll files on its own.
vim.api.nvim_create_autocmd({ 'FocusGained', 'BufEnter', 'CursorHold', 'CursorHoldI' }, {
  desc = 'Check if a file was changed on disk and reload the buffer',
  group = group,
  callback = function()
    if vim.fn.mode() ~= 'c' then vim.cmd 'checktime %' end
  end,
})

vim.api.nvim_create_autocmd('FileChangedShellPost', {
  desc = 'Notify when a buffer was reloaded due to an external file change',
  group = group,
  callback = function() vim.notify('File changed on disk, buffer reloaded', vim.log.levels.WARN) end,
})

-- vim: ts=2 sts=2 sw=2 et
