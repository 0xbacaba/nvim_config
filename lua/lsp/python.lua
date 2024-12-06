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
            utils.ask_pip_install,
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
      cmd = {
        require("utils.pyvenv").get_pyvenv() .. "/bin/pylsp",
      },
    })

    require("utils.pyvenv").pip_install_needed "python-lsp-server"
    require("lspconfig").pylsp.setup(config)
  end,
}

return M
