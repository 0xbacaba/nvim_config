----------------------------------------
--- os information utility functions ---
----------------------------------------

local M
M = {
  OS = {
    linux = "Linux",
    macos = "Darwin",
  },
  ARCH = {
    arm = { "arm64", "aarch64" },
    x86 = { "x86_64" },
  },
  --- @return string
  get_uname = function()
    local uname, _ = vim.fn.system("uname"):gsub("%s+", "")
    return uname
  end,
  --- @return string
  get_architecture = function()
    local arch, _ = vim.fn.system("uname -m"):gsub("%s+", "")
    return arch
  end,
  --- @param arch table<string>
  --- @return boolean
  is_architecture = function(arch) return vim.tbl_contains(arch, M.get_architecture()) end,
}
return M
