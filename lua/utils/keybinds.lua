------------------------------------------
--- keybind specific utility functions ---
------------------------------------------

local mode = {
  normal = 0,
  visual = 1,
}

local definitions = {
  lsp = {
    {
      "Go to declaration",
      "<leader>lD",
      mode.normal,
      vim.lsp.buf.declaration,
    },
    {
      "Go to declaration",
      "<leader>lD",
      mode.normal,
      vim.lsp.buf.declaration,
    },
    {
      "Go to definition",
      "<leader>ld",
      mode.normal,
      vim.lsp.buf.definition,
    },
    {
      "Go to implementation",
      "<leader>li",
      mode.normal,
      vim.lsp.buf.implementation,
    },
    {
      "Hover text",
      "<leader>lh",
      mode.normal,
      vim.lsp.buf.hover,
    },
    {
      "Show signature",
      "<leader>lH",
      mode.normal,
      vim.lsp.buf.signature_help,
    },
    {
      "Add workspace folder",
      "<leader>lwa",
      mode.normal,
      vim.lsp.buf.add_workspace_folder,
    },
    {
      "Remove workspace folder",
      "<leader>lwr",
      mode.normal,
      vim.lsp.buf.remove_workspace_folder,
    },
    {
      "Go to type definition",
      "<leader>D",
      mode.normal,
      vim.lsp.buf.type_definition,
    },
    {
      "Rename",
      "<leader>lr",
      mode.normal,
      vim.lsp.buf.rename,
    },
    {
      "Code actions",
      "<leader>la",
      mode.normal,
      vim.lsp.buf.code_action,
    },
    {
      "Format file",
      "<leader>lf",
      mode.normal,
      function() vim.lsp.buf.format { async = true } end,
    },
    {
      "List workspace folders",
      "<leader>lwl",
      mode.normal,
      function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    },
    {
      "Code actions",
      "<leader>la",
      mode.visual,
      vim.lsp.buf.code_action,
    },
  },
  global = {
    {
      "Resize split left",
      "<S-Left>",
      mode.normal,
      function() require("smart-splits").resize_left() end,
    },
    {
      "Resize split right",
      "<S-Right>",
      mode.normal,
      function() require("smart-splits").resize_right() end,
    },
    {
      "Resize split up",
      "<S-UP>",
      mode.normal,
      function() require("smart-splits").resize_up() end,
    },
    {
      "Resize split down",
      "<S-Down>",
      mode.normal,
      function() require("smart-splits").resize_down() end,
    },
  },
}

return {
  mapmode = mode,
  map = function(mapmode, lhs, rhs, bufopts, desc)
    if lhs == nil or rhs == nil then
      vim.notify("tried to map nil value " .. tostring(lhs) .. " -> " .. tostring(rhs), vim.log.levels.WARN)
      return
    end
    bufopts.desc = desc
    vim.keymap.set(mapmode, lhs, rhs, bufopts)
  end,
  nmap = function(lhs, rhs, bufopts, desc) require("utils").map("n", lhs, rhs, bufopts, desc) end,
  vmap = function(lhs, rhs, bufopts, desc) require("utils").map("v", lhs, rhs, bufopts, desc) end,
  set_keybinds = function(keybinds, bufnr)
    local utils = require "utils"
    local bufopts = { silent = true, buffer = bufnr }

    for _, def in ipairs(keybinds) do
      local func
      if def[3] == mode.normal then
        func = utils.nmap
      elseif def[3] == mode.visual then
        func = utils.vmap
      end

      func(def[2], def[4], bufopts, def[1])
    end
  end,
  set_lsp_keybinds = function(_, bufnr) require("utils").set_keybinds(definitions.lsp, bufnr) end,
  set_global_keybinds = function(_, bufnr) require("utils").set_keybinds(definitions.global, bufnr) end,
}
