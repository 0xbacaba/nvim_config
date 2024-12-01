----------------------------------------
--- os information utility functions ---
----------------------------------------

return {
  OS = {
    linux = "Linux",
    macos = "Darwin",
  },
  get_uname = function() return vim.fn.system("uname"):gsub("%s+", "") end,
  get_architecture = function() return vim.fn.system("uname -m"):gsub("%s+", "") end,
}
