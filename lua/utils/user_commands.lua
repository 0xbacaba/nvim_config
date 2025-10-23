---------------------------------------
--- Custom user command definitions ---
---------------------------------------

---@type table<table<string, function, table>>
local user_commands = {
  {
    command = "ToHtml",
    func = function()
      local current_bufnr = vim.api.nvim_get_current_buf()
      local current_bufname = vim.api.nvim_buf_get_name(current_bufnr)
      local lines = require("tohtml").tohtml()
      if lines then
        local bufnr = vim.api.nvim_create_buf(true, false)
        vim.api.nvim_buf_set_name(bufnr, current_bufname .. ".html")
        vim.api.nvim_buf_set_var(bufnr, "filetype", "html")
        vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
        vim.api.nvim_set_current_buf(bufnr)
      end
    end,
    opts = {},
  },
  {
    command = "LspRoot",
    func = function()
      local lsp_common = require "lsp.common"
      local add_root_dir_title = "Add root dir"
      require("utils.user_input").show_selection_tree("Select action", {
        add_root_dir_title,
        ["Remove root dir"] = lsp_common.get_root_dirs(),
      }, function(selection)
        if selection == add_root_dir_title then
          vim.ui.input({ prompt = "Path: ", default = vim.fn.getcwd(), completion = "dir" }, function(input)
            if input == add_root_dir_title then
              vim.notify("invalid root dir", vim.log.levels.ERROR)
              return
            end
            lsp_common.add_root_dir(input)
          end)
        else
          lsp_common.remove_root_dir(selection)
        end
      end)
    end,
    opts = {},
  },
}

local M = {
  setup_user_commands = function()
    for _, v in ipairs(user_commands) do
      vim.api.nvim_create_user_command(v.command, v.func, v.opts)
    end
  end,
}
return M
