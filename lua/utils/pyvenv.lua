-------------------------------------
--- python venv utility functions ---
-------------------------------------

local function pylsp_dir() return require("mason-registry").get_package("python-lsp-server"):get_install_path() end
local function pyvenv_dir() return pylsp_dir() .. "/venv" end

local setting_up_pyvenv = false

local M
M = {
  setup_pyvenv = function()
    local pyvenv = pyvenv_dir()

    if vim.fn.isdirectory(pyvenv) == 1 then
      vim.g.python3_host_prog = pyvenv .. "/bin/python3"
      return
    end

    if setting_up_pyvenv then return end
    setting_up_pyvenv = true

    if pylsp_dir() == "" then return end

    vim.notify "Setting up nvim pyvenv"

    -- ensure the pylsp_install directory exists
    vim.fn.mkdir(pyvenv, "p")

    local utils = require "utils"
    utils.run("python3", { "-m", "venv", pyvenv }, function(code)
      if code ~= 0 then
        vim.notify("Failed to create python virtual environment at " .. pyvenv, vim.log.levels.ERROR)
        return
      end

      vim.g.python3_host_prog = pyvenv .. "/bin/python3"
    end)
  end,

  ---@return string|nil
  get_pyvenv = function()
    local pyvenv = pyvenv_dir()
    if vim.fn.isdirectory(pyvenv) == 0 or vim.fn.executable(pyvenv .. "/bin/python3") == 0 then M.setup_pyvenv() end

    return pyvenv
  end,

  ---@param package string|nil
  ask_pip_install = function(package)
    local venv = M.get_pyvenv()
    if venv == nil then return end
    local python = venv .. "/bin/python3"

    local utils = require "utils"
    local command = python .. " -m pip install "
    if package ~= nil then command = command .. package end
    utils.ask_to_run(command, function(success)
      if success then
        vim.schedule(function() vim.notify(package .. " installation successful") end)
        return
      end

      vim.schedule(function() vim.notify(package .. " installation failed", vim.log.levels.WARN) end)
    end)
  end,

  ---@param package string|table
  pip_install_needed = function(package)
    if type(package) == "table" then
      for _, v in ipairs(package) do
        M.pip_install_needed(v)
      end
      return
    end
    if type(package) ~= "string" then
      vim.notify(
        "`package` must be a string, got:" .. type(package) .. " " .. require("utils").deep_tostring(package),
        vim.log.levels.ERROR
      )
      return
    end

    local venv = M.get_pyvenv()
    if venv == nil then return end

    local python = venv .. "/bin/python3"

    local utils = require "utils"

    utils.run(python, { "-m", "pip", "install", package }, function(code)
      if code == 0 then return end

      vim.schedule(function() vim.notify(package .. " installation failed: " .. code, vim.log.levels.WARN) end)
    end)
  end,
}

return M
