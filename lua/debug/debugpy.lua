return {
  setup = function()
    local utils = require "utils"
    local python = utils.get_pyvenv() .. "/bin/python3"

    local flag_file = utils.get_flag_dir() .. "/debugpy_install"
    if vim.fn.filereadable(flag_file) ~= 1 then
      vim.fn.writefile({}, flag_file)

      utils.pip_install_needed "debugpy"
    end

    require("dap-python").setup(python)

    local dap = require "dap"
    local configs = dap.configurations

    -- Replace "Attach remote" python debug configuration
    local remote_index = -1
    for i, config in ipairs(configs.python) do
      if config.name == "Attach remote" then
        remote_index = i
        break
      end
    end
    if remote_index == -1 then
      vim.notify("[debugpy] 'Attach remote' config not found", vim.log.levels.WARN)
      return
    end

    configs.python[remote_index] = {
      type = "python",
      request = "attach",
      name = "Attach remote",
      connect = function()
        local host = vim.fn.input "Host [127.0.0.1]: "
        host = host ~= "" and host or "127.0.0.1"

        local port = tonumber(vim.fn.input "Port [5678]: ") or 5678

        return { host = host, port = port }
      end,
      pathMappings = {
        { localRoot = "${workspaceFolder}", remoteRoot = "." },
      },
    }
  end,
}
