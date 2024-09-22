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
    config = function() require("lsp/java").setup() end,
  },
  {
    "mfussenegger/nvim-jdtls",
  },
  {
    "mfussenegger/nvim-dap",
  },
}
