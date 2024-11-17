return {
  setup = function()
    local pylsp_install = require("mason-registry").get_package("python-lsp-server"):get_install_path()
    local utils = require "utils"
    local pylsp_python = pylsp_install .. "/venv/bin/python3"

    local flag_file = utils.get_flag_dir() .. "/debugpy_install"
    if vim.fn.filereadable(flag_file) ~= 1 then
      vim.fn.writefile({}, flag_file)

      utils.run(pylsp_python, { "-m", "debugpy", "--version" }, function(code)
        if code == 0 then return end

        vim.notify "Installing debugpy"
        utils.run(pylsp_python, { "-m", "pip", "install", "debugpy" }, function(install_code)
          if install_code ~= 0 then
            vim.schedule(
              function() vim.notify("Debugpy installation failed: " .. install_code, vim.log.levels.ERROR) end
            )
            return
          end

          vim.schedule(function() vim.notify "Debugpy installation successful" end)
        end)
      end)
    end

    require("dap-python").setup(pylsp_python)

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
