local M
M = {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      on_attach = function(client, bufnr)
        local utils = require "utils"

        utils.set_lsp_keybinds(client, bufnr)

        utils.set_keybinds({
          {
            "Install package with pip",
            "<leader>lp",
            utils.mapmode.normal,
            M.pip_install,
          },
        }, bufnr)
      end,
      settings = {
        pylsp = {
          plugins = {
            pycodestyle = {
              ignore = { "W391" },
              maxLineLength = 200,
            },
          },
        },
      },
    })

    require("lspconfig").pylsp.setup(config)
  end,
  pip_install = function(package)
    local pylsp_install = require("mason-registry").get_package("python-lsp-server"):get_install_path()
    local utils = require "utils"
    local pylsp_python = pylsp_install .. "/venv/bin/python3"

    utils.ask_to_run(pylsp_python .. " -m pip install ", function(install_success)
      if install_success then
        vim.notify "Installation successful"
        return
      end

      vim.notify("Installation failed", vim.log.levels.ERROR)
    end)
  end,
}

return M
