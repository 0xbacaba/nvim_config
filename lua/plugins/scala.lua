return {
  "scalameta/nvim-metals",
  ft = { "scala", "sbt" },
  opts = function()
    local utils = require("utils.keybinds")
    local metals_config = require("metals").bare_config()
    metals_config.on_attach = function(client, bufnr)
      require("metals").setup_dap()

      utils.set_lsp_keybinds(client, bufnr)
    end
    return metals_config
  end,
  config = function(self, metals_config)
    local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = self.ft,
      callback = function()
        require("metals").initialize_or_attach(metals_config)
      end,
      group = nvim_metals_group,
    })
  end
}
