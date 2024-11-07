local keybinds = require "utils.keybinds"
local data = require "utils.data"
local color = require "utils.color"

return vim.tbl_deep_extend("force", keybinds, data, color, {
  ask_to_run = function(command, callback)
    local cmd = vim.fn.input("Run command: ", command)
    if cmd == "" then return end

    local handle
    handle = vim.uv.spawn("sh", {
      args = { "-c", cmd },
      stdio = { nil, vim.uv.new_pipe(false), vim.uv.new_pipe(false) },
    }, function(code, _)
      if handle ~= nil then handle:close() end

      if callback ~= nil then vim.schedule(function() callback(code == 0) end) end
    end)
  end,
})
