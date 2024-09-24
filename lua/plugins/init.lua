return {
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "rust_analyzer",
        "taplo",

        "tsserver",

        "jdtls",
        "java-debug",
        "java-test",

        "clangd",
      },
      automatic_installation = true,
    },
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      local lspconfig = require "lspconfig"
      local mason_lspconfig = require "mason-lspconfig"

      local utils = require "utils"
      local default_config = { on_attach = utils.set_lsp_keybinds }

      mason_lspconfig.setup_handlers {
        function(server_name) lspconfig[server_name].setup(default_config) end,
      }

      require("lsp/java").setup(default_config)
      require("lsp/clangd").setup(default_config)
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
  },
  {
    "mfussenegger/nvim-dap",
  },
}
