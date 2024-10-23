local utils = require "utils"

local function is_arduino_project(lspclient)
  if lspclient.config.root_dir == nil then return false end
  return vim.fn.glob(lspclient.config.root_dir .. "/*.ino") ~= ""
end
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

local function ask_to_compile(client, callback)
  local root_dir = client.config.root_dir
  local compile_command = "arduino-cli compile"
  if vim.fn.findfile("Makefile", root_dir) ~= "" then compile_command = "make" end
  local args = vim.fn.input("", compile_command)
  if args == "" then return end
  local handle
  handle = vim.uv.spawn("sh", {
    args = { "-c", args },
    stdio = { nil, vim.uv.new_pipe(false), vim.uv.new_pipe(false) },
  }, function(code, _)
    if handle ~= nil then handle:close() end

    if code == 0 then
      vim.schedule(function()
        vim.notify("Compilation finished", vim.log.levels.INFO)
        if callback ~= nil then callback() end
      end)
    else
      vim.schedule(function() vim.notify("Compilation failed", vim.log.levels.ERROR) end)
    end
  end)
end

return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"

    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = { "clangd" },
      on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        utils.set_lsp_keybinds(client, bufnr)

        local neotest = require "neotest"
        utils.nnoremap("<leader>dt", function() neotest.run.run(vim.fn.expand "%") end, bufopts, "Test File")
        utils.nnoremap("<leader>dT", neotest.run.run, bufopts, "Test")
        utils.nnoremap("<leader>dS", neotest.summary.toggle, bufopts, "Toggle Test Summary")

        if is_arduino_project(client) then
          utils.nnoremap("<leader>lc", function() ask_to_compile(client) end, bufopts, "compile")
          for _, flag in ipairs(client.config.cmd) do
            if flag:match "^%-%-compile%-commands%-dir=" then return end
          end

          local build_dir = find_arduino_build_dir(client.config.root_dir)
          if build_dir == nil then
            local should_compile = vim.fn.confirm("No build directory found. Compile now?", "&Yes\n&No", 1)
            if should_compile ~= 2 then ask_to_compile(client, function() vim.cmd "LspRestart" end) end

            build_dir = client.config.root_dir
            return
          end
          client.config.cmd = vim.list_extend(client.config.cmd, { "--compile-commands-dir=" .. build_dir })
          vim.cmd "LspRestart"
        end
      end,
      root_dir = lspconfig.util.root_pattern(
        "sketch.yaml", -- arduino-specific
        "*.ino",

        ".git", -- general
        "CMakeLists.txt"
      ),
      filetypes = { "c", "cpp", "arduino" },
      init_options = {
        cmopleteUnimported = true,
      },
    })

    lspconfig.clangd.setup(config)
  end,
}
