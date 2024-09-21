return {
  nnoremap = function(rhs, lhs, bufopts, desc)
    bufopts.desc = desc
    vim.keymap.set("n", rhs, lhs, bufopts)
  end,
  vnoremap = function(rhs, lhs, bufopts, desc)
    bufopts.desc = desc
    vim.keymap.set("v", rhs, lhs, bufopts)
  end,
  set_lsp_keybinds = function(_client, bufnr)
    local utils = require "utils"
    local bufopts = { noremap = true, silent = true, buffer = bufnr }
    utils.nnoremap("<leader>lD", vim.lsp.buf.declaration, bufopts, "Go to declaration")
    utils.nnoremap("<leader>ld", vim.lsp.buf.definition, bufopts, "Go to definition")
    utils.nnoremap("<leader>li", vim.lsp.buf.implementation, bufopts, "Go to implementation")
    utils.nnoremap("<leader>lh", vim.lsp.buf.hover, bufopts, "Hover text")
    utils.nnoremap("<leader>lH", vim.lsp.buf.signature_help, bufopts, "Show signature")
    utils.nnoremap("<leader>lwa", vim.lsp.buf.add_workspace_folder, bufopts, "Add workspace folder")
    utils.nnoremap("<leader>lwr", vim.lsp.buf.remove_workspace_folder, bufopts, "Remove workspace folder")
    utils.nnoremap(
      "<leader>lwl",
      function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
      bufopts,
      "List workspace folders"
    )
    utils.nnoremap("<leader>D", vim.lsp.buf.type_definition, bufopts, "Go to type definition")
    utils.nnoremap("<leader>lr", vim.lsp.buf.rename, bufopts, "Rename")
    utils.nnoremap("<leader>la", vim.lsp.buf.code_action, bufopts, "Code actions")
    utils.vnoremap("<leader>la", vim.lsp.buf.range_code_action, bufopts, "Code actions")
    utils.nnoremap("<leader>lf", function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")
  end,
}
