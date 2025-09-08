return {
  setup = function()
    local dap = require "dap"

    local codelldb_path = require("mason-registry").get_package("codelldb"):get_install_path()
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb_path .. "/extension/adapter/codelldb",
        args = { "--port", "${port}" },
      },
    }

    local cwdLogical = vim.fn.trim(vim.fn.system { "pwd", "-L" })
    local cwdPhysical = vim.fn.trim(vim.fn.system { "pwd", "-P" })

    local sourceMapping = nil
    if cwdLogical ~= cwdPhysical then
      sourceMapping = {
        [cwdLogical] = cwdPhysical,
        [cwdPhysical] = cwdLogical,
      }
    end

    local conf = dap.configurations
    conf.cpp = {
      {
        name = "default",
        type = "codelldb",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        sourceMap = sourceMapping,
      },
    }
    conf.c = conf.cpp
    conf.arduino = conf.cpp
  end,
}
