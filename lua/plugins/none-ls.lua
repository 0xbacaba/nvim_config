return {
  {
    "nvimtools/none-ls.nvim",
    branch = "main",
    commit = nil,
    tag = nil,
    version = nil,
    config = function()
      local null_ls = require "null-ls"
      null_ls.setup {
        debug = true,
        sources = {
          null_ls.builtins.formatting.stylua,
          null_ls.builtins.formatting.clang_format.with {
            command = "/usr/bin/clang-format"
          }
        },
        on_attach = function(client, bufnr)
          local ignored_filetypes = {
            "java",
          }
          local filetype = vim.bo[bufnr].filetype

          if vim.tbl_contains(ignored_filetypes, filetype) then client.stop() end
        end,
      }
    end,
  },
}
