return {
  {
    "williamboman/mason.nvim",
    config = function() require("mason").setup { ui = { border = "rounded" } } end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
    },
    config = function()
      local ensure_installed = {
        "lua_ls",
        "rust_analyzer",
        "taplo",
        "jdtls",
        "texlab",
        "pylsp",
      }
      if vim.fn.executable "npm" == 1 then table.insert(ensure_installed, "ts_ls") end
      local os = require "utils.os"
      if os.get_uname() ~= os.OS.linux and os.is_architecture(os.ARCH.arm) then
        table.insert(ensure_installed, "clangd")
      end

      require("mason-lspconfig").setup {
        ensure_installed = ensure_installed,
        automatic_installation = true,
      }
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
      if vim.fn.executable "clangd" == 1 then require("lsp/clangd").setup(default_config) end
      require("lsp/latex").setup(default_config)
      require("lsp/python").setup(default_config)
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
        ignore_install = { "latex" },
      }
    end,
  },
  { "mfussenegger/nvim-jdtls" },
  { "mfussenegger/nvim-dap-python" },
}
