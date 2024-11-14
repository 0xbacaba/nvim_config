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
  end,
}
