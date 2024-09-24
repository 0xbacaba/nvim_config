local utils = require "utils"

local function is_arduino_project(lspclient) return vim.fn.glob(lspclient.config.root_dir .. "/*.ino") ~= "" end
local function find_arduino_build_dir(project_dir)
  local potential_dirs = vim.fn.split(vim.fn.glob(utils.get_temp_dir() .. "/arduino/sketches/*/"), "\n")

  for _, dir in ipairs(potential_dirs) do
    local file = io.open(dir .. "/build.options.json", "r")
    if file then
      local content = file:read "*a"

      if content:match '"sketchLocation": "(.+)"' == project_dir then return dir end
    end
  end

  return nil
end

return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"

    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = { "clangd" },
      on_attach = function(client, bufnr)
        utils.set_lsp_keybinds(client, bufnr)

        if is_arduino_project(client) then
          for _, flag in ipairs(client.config.cmd) do
            if flag:match "^%-%-compile%-commands%-dir=" then return end
          end

          local buf_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":h")
          local build_dir = find_arduino_build_dir(buf_dir)
          if build_dir == nil then
            vim.notify "no build directory found, try compiling first"
            return
          end
          client.config.cmd = vim.list_extend(client.config.cmd, { "--compile-commands-dir=" .. build_dir })
          vim.cmd "LspRestart"
        end
      end,
      root_dir = lspconfig.util.root_pattern(
        ".git", -- general
        "CMakeLists.txt",

        "sketch.yaml", -- arduino-specific
        "*.ino"
      ),
      filetypes = { "c", "cpp", "arduino" },
      init_options = {
        cmopleteUnimported = true,
      },
    })

    lspconfig.clangd.setup(config)
  end,
}
