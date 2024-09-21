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
      },
      automatic_installation = true,
    },
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
