-- Omarchy's Neovim layer, read from the omarchy-pkgs repo instead of copied in,
-- so every machine (macOS included) tracks it. lazy.nvim updates the repo and
-- pins its commit in lazy-lock.json like any other plugin.
local M = {}

M.repo = vim.fn.stdpath("data") .. "/lazy/omarchy-pkgs"
M.dir = M.repo .. "/pkgbuilds/omarchy-nvim"

function M.bootstrap()
  if not vim.uv.fs_stat(M.repo) then
    local url = "https://github.com/omacom/omarchy-pkgs.git"
    local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--sparse", url, M.repo })
    -- the repo holds every Omarchy package; check out only the nvim one
    if vim.v.shell_error == 0 then
      out = vim.fn.system({ "git", "-C", M.repo, "sparse-checkout", "set", "pkgbuilds/omarchy-nvim" })
    end
    if vim.v.shell_error ~= 0 then
      vim.api.nvim_echo({ { "Failed to clone omarchy-pkgs:\n", "ErrorMsg" }, { out, "WarningMsg" } }, true, {})
    end
  end

  -- Omarchy's files require their own modules (config.remote_clipboard).
  -- This path is searched after the config dir, so a file of the same name here wins.
  package.path = package.path .. ";" .. M.dir .. "/lua/?.lua"
end

function M.load(path)
  return dofile(M.dir .. "/" .. path)
end

return M
