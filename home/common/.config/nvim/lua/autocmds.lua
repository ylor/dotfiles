-- [[ Autosave / Autoreload ]]
--  See `:help autocommand`

local group = vim.api.nvim_create_augroup('kickstart-autosave-autoreload', { clear = true })

-- Autosave: silently write the current buffer when it loses focus (switching
-- windows/buffers or leaving insert mode) or when Neovim itself loses focus.
-- Buftype guards against terminal/scratch buffers; `silent!` swallows the rest
-- (unnamed, readonly, non-modifiable) the same way `:write` already would.
vim.api.nvim_create_autocmd({ 'FocusLost', 'BufLeave', 'InsertLeave' }, {
  desc = 'Autosave the current buffer on focus/buffer change',
  group = group,
  callback = function(event)
    local buf = event.buf
    if vim.bo[buf].buftype ~= '' or not vim.bo[buf].modified then return end
    vim.api.nvim_buf_call(buf, function() vim.cmd 'silent! write' end)
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
