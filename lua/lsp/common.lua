local function get_root_dir_flag()
  local utils = require "utils.data"
  local root_dir_flag = utils.get_flag_dir() .. "/root_dirs"
  if vim.fn.filereadable(root_dir_flag) ~= 1 then vim.fn.writefile({}, root_dir_flag) end

  return root_dir_flag
end

local M
M = {
  ---@param dir string
  add_root_dir = function(dir)
    local flag = get_root_dir_flag()
    local dirs = vim.fn.readfile(flag)
    if vim.tbl_contains(dirs, dir) then return end

    vim.fn.writefile({ dir }, flag, "a")
    vim.cmd "LspRestart"
  end,
  ---@param dir string
  remove_root_dir = function(dir)
    local flag = get_root_dir_flag()
    local dirs = vim.fn.readfile(flag)
    if not vim.tbl_contains(dirs, dir) then return end

    local new_dirs = vim.tbl_filter(function(d) return d ~= dir end, dirs)
    vim.fn.writefile(new_dirs, flag)
    vim.cmd "LspRestart"
  end,

  ---@return string[]
  get_root_dirs = function() return vim.fn.readfile(get_root_dir_flag()) end,
  ---@param ...any
  root_pattern = function(...)
    local lspconfig_root_pattern = require("lspconfig").util.root_pattern(...)
    return function(startpath)
      -- check if the startpath starts with any configured root dir
      for _, v in ipairs(M.get_root_dirs()) do
        if v ~= "" then
          if startpath:sub(0, v:len()) == v then return v end
        end
      end
      -- otherwise use the lspconfig root pattern
      return lspconfig_root_pattern(startpath)
    end
  end,
}
return M
