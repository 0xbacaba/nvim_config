local utils = require "utils"
local arduino = require "utils.arduino"

---@param list table<string>
---@param pattern string
local function listHas(list, pattern)
  for _, flag in ipairs(list) do
    if flag:match(pattern) then return true end
  end
  return false
end

local function find_compile_commands(client, bufopts)
  -- skip checks for compile_commands if in single-file mode
  if client.config.root_dir == nil then return end

  -- ensure there's no duplicate `--compile-commands-dir` flag
  if not listHas(client.config.cmd, "^%-%-compile%-commands%-dir=") then
    -- search for compile_commands.json in these dirs:
    local compile_command_search_dirs = { client.config.root_dir, client.config.root_dir .. "/build" }

    for _, dir in ipairs(compile_command_search_dirs) do
      local compile_commands = dir .. "/compile_commands.json"
      if vim.fn.filereadable(compile_commands) == 1 then
        vim.list_extend(client.config.cmd, { "--compile-commands-dir=" .. dir })
        break
      end
    end
  end

  if arduino.is_arduino_project(client) then
    utils.nmap("<leader>lc", function() arduino.ask_to_compile(client) end, bufopts, "compile")
    if listHas(client.config.cmd, "^%-%-compile%-commands%-dir=") then return end

    local build_dir = arduino.find_project_build_dir(client.config.root_dir)
    if build_dir == nil then
      local should_compile = vim.fn.confirm("No build directory found. Compile now?", "&Yes\n&No", 1)
      if should_compile ~= 2 then arduino.ask_to_compile(client, function() vim.cmd "LspRestart" end) end

      build_dir = client.config.root_dir
      return
    end
    client.config.cmd = vim.list_extend(client.config.cmd, { "--compile-commands-dir=" .. build_dir })
    vim.cmd "LspRestart"
  end
end

return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"
    local lspcommon = require "lsp.common"

    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = {
        "clangd",
        "--completion-style=detailed",
        "--fallback-style=none",
        "--clang-tidy",
        "--log=verbose",
      },
      on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        utils.set_lsp_keybinds(client, bufnr)

        local neotest = require "neotest"
        utils.nmap("<leader>dt", function() neotest.run.run(vim.fn.expand "%") end, bufopts, "Test File")
        utils.nmap("<leader>dT", neotest.run.run, bufopts, "Test")
        utils.nmap("<leader>dS", neotest.summary.toggle, bufopts, "Toggle Test Summary")

        find_compile_commands(client, bufopts)
      end,
      root_dir = lspcommon.root_pattern(
        "compile_commands.json",

        "sketch.yaml", -- arduino-specific
        "*.ino",

        ".gitmodules", -- general
        ".git",
        "CMakeLists.txt"
      ),
      filetypes = { "c", "cpp", "arduino" },
      init_options = {
        completeUnimported = true,
      },
    })

    lspconfig.clangd.setup(config)
  end,
}
