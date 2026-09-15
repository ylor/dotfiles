-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
require("config.remote_clipboard").setup()

vim.opt.relativenumber = false
vim.opt.signcolumn = "auto"
vim.g.autoformat = false

vim.opt.wrap = true
vim.opt.textwidth = 100
vim.opt.colorcolumn = "100"
