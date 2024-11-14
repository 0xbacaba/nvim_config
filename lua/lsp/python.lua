return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
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
}
