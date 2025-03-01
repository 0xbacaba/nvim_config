local keybinds = require "utils.keybinds"
local data = require "utils.data"
local color = require "utils.color"
local os = require "utils.os"
local pyvenv = require "utils.pyvenv"
local user_input = require "utils.user_input"
local user_commands = require "utils.user_commands"

local M
M = vim.tbl_deep_extend("force", keybinds, data, color, os, pyvenv, user_input, user_commands, {
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
  deep_tostring = function(obj, indent)
    indent = indent or 0
    local prefix = string.rep("  ", indent)
    local result = ""

    if type(obj) == "table" then
      result = result .. prefix .. "{\n"
      for key, value in pairs(obj) do
        local keyStr = tostring(key)
        result = result .. prefix .. "  [" .. keyStr .. "] = "
        result = result .. M.deep_tostring(value, indent + 1)
      end
      result = result .. prefix .. "}\n"
    else
      result = result .. prefix .. tostring(obj) .. "\n"
    end

    return result
  end,
})

return M
