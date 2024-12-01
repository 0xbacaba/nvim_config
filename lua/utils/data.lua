---------------------------------------
--- data specific utility functions ---
---------------------------------------

local home = os.getenv "HOME"

return {
  xdg_data_home = os.getenv "XDG_DATA_HOME" or home .. "/.local/share",
  xdg_cache_home = os.getenv "XDG_CACHE_HOME" or home .. "/.cache",
  find_nvim_data = function()
    local utils = require "utils"
    local default = home .. "/.local/share/nvim"
    local potential_paths = {
      utils.xdg_data_home and (utils.xdg_data_home .. "/nvim"),
      default,
    }

    for _, path in ipairs(potential_paths) do
      if vim.fn.isdirectory(path) then return path end
    end

    vim.notify("could not find nvim data directory. Will default to " .. default, vim.log.levels.WARN)
    return default
  end,
  find_nvim_cache = function()
    local utils = require "utils"
    local default = home .. "/.cache/nvim"
    local potential_paths = {
      utils.xdg_cache_home and (utils.xdg_cache_home .. "/nvim"),
      default,
    }

    for _, path in ipairs(potential_paths) do
      if vim.fn.isdirectory(path) then return path end
    end

    vim.notify("could not find nvim cache directory. Will default to " .. default, vim.log.levels.WARN)
    return default
  end,
  get_temp_dir = function() return os.getenv "TMPDIR" or os.getenv "TEMP" or os.getenv "TMP" or "/tmp" end,
  get_flag_dir = function()
    local dir = vim.fn.stdpath "data" .. "/custom_flags"
    if vim.fn.isdirectory(dir) then return dir end

    vim.fn.mkdir(dir)
    return dir
  end,
}
