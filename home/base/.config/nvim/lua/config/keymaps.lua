-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- LazyVim already does this in normal/visual mode; extend it to insert mode.
vim.keymap.set("i", "<Down>", "<C-o>gj", { desc = "Down (display line)", silent = true })
vim.keymap.set("i", "<Up>", "<C-o>gk", { desc = "Up (display line)", silent = true })
