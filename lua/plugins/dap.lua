return {
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      require("mason-nvim-dap").setup {
        ensure_installed = {
          "javadbg",
          "javatest",

          "codelldb",

          "debugpy",
        },
        automatic_installation = true,
      }

      require("debug/codelldb").setup()
      require("debug/jdtls").setup()
      require("debug/debugpy").setup()
    end,
  },
  {
    "mfussenegger/nvim-dap",
    config = function()
      if vim.version.ge(vim.version(), { 0, 11, 0 }) then
        vim.api.nvim_create_autocmd("FileType", {
          pattern = {
            "dapui_scopes",
            "dapui_breakpoints",
            "dapui_stacks",
            "dapui_watches",
            "dapui_console",
          },
          callback = function() vim.opt_local.winborder = "none" end,
        })
      end
    end,
  },
  {
    "stevearc/overseer.nvim",
    config = function() require("overseer").setup() end,
  },
}
