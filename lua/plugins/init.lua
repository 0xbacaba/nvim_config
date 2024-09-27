return {
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup() end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      require("mason-lspconfig").setup {
        ensure_installed = {
          "rust_analyzer",
          "taplo",
          "ts_ls",
          "jdtls",
          "clangd",
        },
        automatic_installation = true,
      }
    end,
  },
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
        },
        automatic_installation = true,
      }

      require("debug/codelldb").setup()
      require("debug/jdtls").setup()
    end,
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
    "nvim-treesitter/nvim-treesitter",
    config = function()
      require("nvim-treesitter.configs").setup {
        ensure_installed = { "c", "cpp", "arduino", "lua", "java" },
        sync_install = false,
        auto_install = true,
        modules = {},
        ignore_install = {},
      }
    end,
  },
  { "mfussenegger/nvim-jdtls" },
  { "mfussenegger/nvim-dap" },
  {
    "stevearc/overseer.nvim",
    config = function() require("overseer").setup() end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "alfaix/neotest-gtest",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require("neotest-gtest").setup {},
        },
      }
    end,
  },
}
