-- [[ Autosave / Autoreload ]]
--  See `:help autocommand`

local group = vim.api.nvim_create_augroup('kickstart-autosave-autoreload', { clear = true })

-- Autosave: write the current buffer on any text change or leaving insert
-- mode; `autowriteall` covers the focus/buffer-switch cases (`:help 'aw'`).
vim.opt.autowriteall = true

vim.api.nvim_create_autocmd({ 'InsertLeavePre', 'TextChanged', 'TextChangedP' }, {
  desc = 'Autosave the current buffer',
  group = group,
  callback = function()
    if vim.bo.modifiable and not vim.bo.readonly then pcall(function() vim.cmd 'update' end) end
  end,
})

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
