local home = os.getenv "HOME"

return {
  nnoremap = function(lhs, rhs, bufopts, desc)
    if lhs == nil or rhs == nil then
      vim.notify("tried to nmap nil value " .. tostring(lhs) .. " -> " .. tostring(rhs), vim.log.levels.WARN)
      return
    end
    bufopts.desc = desc
    vim.keymap.set("n", lhs, rhs, bufopts)
  end,
  vnoremap = function(lhs, rhs, bufopts, desc)
    if lhs == nil or rhs == nil then
      vim.notify("tried to vmap nil value " .. tostring(lhs) .. " -> " .. tostring(rhs), vim.log.levels.WARN)
      return
    end
    bufopts.desc = desc
    vim.keymap.set("v", lhs, rhs, bufopts)
  end,
  set_lsp_keybinds = function(_, bufnr)
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
    utils.vnoremap("<leader>la", vim.lsp.buf.code_action, bufopts, "Code actions")
    utils.nnoremap("<leader>lf", function() vim.lsp.buf.format { async = true } end, bufopts, "Format file")
  end,
  xdg_data_home = os.getenv "XDG_DATA_HOME" or home .. "/.local/share",
  xdg_cache_home = os.getenv "XDG_CACHE_HOME" or home .. "/.cache",
  find_nvim_data = function()
    local utils = require "utils"
    local default = home .. "/.local/share/nvim"
    local potential_paths = {
      utils.xdg_data_home and (utils.xdg_data_home .. "/nvim"),
      default,
    }

    for _, path in ipairs(potential_paths) do
      if vim.fn.isdirectory(path) then return path end
    end

    vim.notify("could not find nvim data directory. Will default to " .. default, vim.log.levels.WARN)
    return default
  end,
  find_nvim_cache = function()
    local utils = require "utils"
    local default = home .. "/.cache/nvim"
    local potential_paths = {
      utils.xdg_cache_home,
      default,
    }

    for _, path in ipairs(potential_paths) do
      if vim.fn.isdirectory(path) then return path end
    end

    vim.notify("could not find nvim cache directory. Will default to " .. default, vim.log.levels.WARN)
  end,
  get_temp_dir = function() return os.getenv "TMPDIR" or os.getenv "TEMP" or os.getenv "TMP" or "/tmp" end,
  get_flag_dir = function()
    local dir = vim.fn.stdpath "data" .. "/custom_flags"
    local stat = vim.loop.fs_stat(dir)
    if stat and stat.type == "directory" then return dir end

    vim.fn.mkdir(dir)
    return dir
  end,
  ask_to_run = function(command, callback)
    local cmd = vim.fn.input("Run command: ", command)
    if cmd == "" then return end

    local handle
    handle = vim.uv.spawn("sh", {
      args = { "-c", cmd },
      stdio = { nil, vim.uv.new_pipe(false), vim.uv.new_pipe(false) },
    }, function(code, _)
      if handle ~= nil then handle:close() end

      if callback ~= nil then vim.schedule(function() callback(code == 0) end) end
    end)
  end,
}
