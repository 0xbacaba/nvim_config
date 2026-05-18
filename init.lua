-- This file simply bootstraps the installation of Lazy.nvim and then calls other files for execution
-- This file doesn't necessarily need to be touched, BE CAUTIOUS editing this file and proceed at your own risk.
local lazypath = vim.env.LAZY or vim.fn.stdpath "data" .. "/lazy/lazy.nvim"
if not (vim.env.LAZY or (vim.uv or vim.loop).fs_stat(lazypath)) then
  -- stylua: ignore
  vim.fn.system({ "git", "clone", "--filter=blob:none", "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath })
end
vim.opt.rtp:prepend(lazypath)

-- validate that lazy is available
if not pcall(require, "lazy") then
  -- stylua: ignore
  vim.api.nvim_echo({ { ("Unable to load lazy from: %s\n"):format(lazypath), "ErrorMsg" }, { "Press any key to exit...", "MoreMsg" } }, true, {})
  vim.fn.getchar()
  vim.cmd.quit()
end

require "lazy_setup"
-- require "polish"

vim.cmd [[
  nm ö [
  nm ä ]
]]

vim.o.scrolloff = 5
vim.o.sidescrolloff = 12

if vim.version.ge(vim.version(), { 0, 11, 0 }) then vim.o.winborder = "rounded" end
if vim.version.ge(vim.version(), { 0, 12, 0 }) then
  require("vim._core.ui2").enable {
    enable = true,
    msg = {
      cmd = {
        height = 0.5,
      },
      dialog = {
        height = 0.5,
      },
      msg = {
        height = 0.5,
        timeout = 4000,
      },
      pager = {
        height = 1,
      },
    },
  }
end

require("utils.color").apply_color_overrides()
require("utils.keybinds").set_global_keybinds()
require("utils.pyvenv").setup_pyvenv()
require("utils.user_commands").setup_user_commands()

vim.lsp.util.open_floating_preview = (function(orig)
  return function(contents, syntax, opts, ...)
    opts = opts or {}
    opts.border = opts.border or "rounded"
    return orig(contents, syntax, opts, ...)
  end
end)(vim.lsp.util.open_floating_preview)

local function disable_autoformat(filetype)
  vim.api.nvim_create_autocmd("Filetype", {
    pattern = filetype,
    callback = function() vim.b.autoformat = false end,
  })
end

disable_autoformat "java"
