return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      on_attach = function(client, bufnr)
        default_config.on_attach(client, bufnr)

        if vim.fn.executable "alejandra" == 1 or vim.fn.executable "nixfmt" == 0 then
          client.server_capabilities.documentFormattingProvider = false
          client.server_capabilities.documentRangeFormattingProvider = false
        end
      end,
    })

    vim.lsp.config("nil_ls", config)
    vim.lsp.enable "nil_ls"
  end,
}
