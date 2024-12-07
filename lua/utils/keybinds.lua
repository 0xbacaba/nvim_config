------------------------------------------
--- keybind specific utility functions ---
------------------------------------------

local mode = {
  normal = 0,
  visual = 1,
}

local definitions = {
  lsp = {
    declaration = {
      "Go to declaration",
      "<leader>lD",
      mode.normal,
      vim.lsp.buf.declaration,
    },
    definition = {
      "Go to definition",
      "<leader>ld",
      mode.normal,
      vim.lsp.buf.definition,
    },
    implementation = {
      "Go to implementation",
      "<leader>li",
      mode.normal,
      vim.lsp.buf.implementation,
    },
    hover = {
      "Hover text",
      "<leader>lh",
      mode.normal,
      vim.lsp.buf.hover,
    },
    signature_help = {
      "Show signature",
      "<leader>lH",
      mode.normal,
      vim.lsp.buf.signature_help,
    },
    add_workspace_folder = {
      "Add workspace folder",
      "<leader>lwa",
      mode.normal,
      vim.lsp.buf.add_workspace_folder,
    },
    remove_workspace_folder = {
      "Remove workspace folder",
      "<leader>lwr",
      mode.normal,
      vim.lsp.buf.remove_workspace_folder,
    },
    type_defintion = {
      "Go to type definition",
      "<leader>D",
      mode.normal,
      vim.lsp.buf.type_definition,
    },
    rename = {
      "Rename",
      "<leader>lr",
      mode.normal,
      vim.lsp.buf.rename,
    },
    code_action = {
      "Code actions",
      "<leader>la",
      mode.normal,
      vim.lsp.buf.code_action,
    },
    format = {
      "Format file",
      "<leader>lf",
      mode.normal,
      function() vim.lsp.buf.format { async = true } end,
    },
    list_workspace_folders = {
      "List workspace folders",
      "<leader>lwl",
      mode.normal,
      function() print(vim.inspect(vim.lsp.buf.list_workspace_folders())) end,
    },
  },
  global = {
    resize_left = {
      "Resize split left",
      "<S-Left>",
      mode.normal,
      function() require("smart-splits").resize_left() end,
    },
    resize_right = {
      "Resize split right",
      "<S-Right>",
      mode.normal,
      function() require("smart-splits").resize_right() end,
    },
    resize_up = {
      "Resize split up",
      "<S-UP>",
      mode.normal,
      function() require("smart-splits").resize_up() end,
    },
    resize_down = {
      "Resize split down",
      "<S-Down>",
      mode.normal,
      function() require("smart-splits").resize_down() end,
    },
  },
}

return {
  mapmode = mode,
  keybinds = definitions,
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

    for _, def in pairs(keybinds) do
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
