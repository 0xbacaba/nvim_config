local utils = require "utils"

local M
M = {

  is_arduino_project = function(lspclient)
    if lspclient.config.root_dir == nil then return false end
    return vim.fn.glob(lspclient.config.root_dir .. "/*.ino") ~= ""
  end,
  get_build_dir = function()
    local uname = utils.get_uname()
    local home = os.getenv "HOME"

    if uname == utils.OS.linux then
      return utils.xdg_cache_home .. "/arduino/sketches"
    elseif uname == utils.OS.macos then
      return home .. "/Library/Caches/arduino/sketches"
    end

    return ""
  end,
  find_project_build_dir = function(project_dir)
    local potential_dirs = vim.fn.split(vim.fn.glob(M.get_build_dir() .. "/*/"), "\n")

    for _, dir in ipairs(potential_dirs) do
      local file = io.open(dir .. "/build.options.json", "r")
      if file then
        local content = file:read "*a"

        if content:match '"sketchLocation": "(.+)"' == project_dir then return dir end
      end
    end

    return nil
  end,

  ask_to_compile = function(client, callback)
    local root_dir = client.config.root_dir
    local compile_command = "arduino-cli compile"
    if vim.fn.findfile("Makefile", root_dir) ~= "" then compile_command = "make" end

    utils.ask_to_run(compile_command, function(succeeded)
      if succeeded then
        vim.notify "Compilation successful"
        if callback ~= nil then callback() end
      else
        vim.notify("Compilation failed", vim.log.levels.ERROR)
      end
    end)
  end,
}

return M
