local keybinds = require "utils.keybinds"
local data = require "utils.data"
local color = require "utils.color"

local M
M = vim.tbl_deep_extend("force", keybinds, data, color, {
  run = function(command, args, callback)
    local handle
    handle = vim.uv.spawn(command, {
      args = args,
      stdio = { nil, vim.uv.new_pipe(false), vim.uv.new_pipe(false) },
    }, function(code, _)
      if handle ~= nil then handle:close() end

      if callback ~= nil then vim.schedule(function() callback(code) end) end
    end)
  end,
  ask_to_run = function(command, callback)
    local cmd = vim.fn.input("Run command: ", command)
    if cmd == "" then return end

    M.run("sh", { "-c", cmd }, function(code)
      if callback ~= nil then callback(code == 0) end
    end)
  end,
})

return M
