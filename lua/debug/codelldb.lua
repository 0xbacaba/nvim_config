---@class RustDebugOptions
---@field command string
---@field args string[]

--- Returns a list of lldb command strings that import the scripts for the given language
---@param codelldb_path string The base path to the codelldb installation
---@param lang string The language for which to get the scripts
---@return string[]
local function get_scripts(codelldb_path, lang)
  local scripts_dir = codelldb_path .. "/scripts/" .. lang
  if vim.fn.isdirectory(scripts_dir) == 0 then return {} end

  local scripts_files = vim.fn.readdir(scripts_dir)
  ---@type table<string>
  local scripts_commands = {}
  for _, file in ipairs(scripts_files) do
    if vim.endswith(file, ".py") then
      table.insert(scripts_commands, "command script import " .. scripts_dir .. "/" .. file)
    else
      vim.notify("Entry is not a python file: " .. file ". Skipped!", vim.log.levels.WARN)
    end
  end

  return scripts_commands
end

return {
  setup = function()
    local dap = require "dap"

    local codelldb_path = require("mason-registry").get_package("codelldb"):get_install_path()
    dap.adapters.codelldb = {
      type = "server",
      port = "${port}",
      executable = {
        command = codelldb_path .. "/extension/adapter/codelldb",
        args = { "--port", "${port}" },
      },
    }

    local cwdLogical = vim.fn.trim(vim.fn.system { "pwd", "-L" })
    local cwdPhysical = vim.fn.trim(vim.fn.system { "pwd", "-P" })

    local sourceMapping = nil
    if cwdLogical ~= cwdPhysical then
      sourceMapping = {
        [cwdLogical] = cwdPhysical,
        [cwdPhysical] = cwdLogical,
      }
    end

    local conf = dap.configurations
    conf.cpp = {
      {
        name = "default",
        type = "codelldb",
        request = "launch",
        program = function() return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file") end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        sourceMap = sourceMapping,
      },
    }
    conf.c = conf.cpp
    conf.arduino = conf.cpp

    ---@type RustDebugOptions
    local opts

    conf.rust = {
      {
        name = "default",
        type = "codelldb",
        request = "launch",
        program = function()
          local root_dir = vim.lsp.client.root_dir or vim.fn.getcwd()
          local cargo_toml = root_dir .. "/Cargo.toml"
          local root_dir_base = vim.fn.fnamemodify(root_dir, ":t")

          local suggested_binary = root_dir_base
          if vim.fn.filereadable(cargo_toml) ~= 1 then
            vim.lsp.log.warn "Cargo.toml is not readable"
          else
            local contents = table.concat(vim.fn.readfile(cargo_toml), "\n")
            -- captures whatever is inside the quotes after 'name = '
            local name = string.match(contents, 'name = "([^\n"]+)"')

            if name ~= nil then suggested_binary = name end
          end

          if suggested_binary == nil then
            vim.lsp.log.error "Couldn't find appropriate binary name"
            vim.lsp.log.error(vim.inspect {
              root_dir = root_dir,
              cargo_toml = cargo_toml,
              root_dir_base = root_dir_base,
              suggested_binary = suggested_binary,
            })
            suggested_binary = ""
          end

          local command =
            vim.fn.split(vim.fn.input("Binary: ", root_dir .. "/target/debug/" .. suggested_binary, "file"), " ", false)

          vim.lsp.log.warn("command before args:remove: " .. vim.inspect(command))
          local args = vim.deepcopy(command)
          table.remove(args, 1) -- remove first item - i.e. the executable
          vim.lsp.log.warn("command after args:remove: " .. vim.inspect(command))

          local binary = vim.fn.fnamemodify(command[1], ":t")
          local output = vim.system({ "cargo", "build", "--bin", binary }):wait()
          if output.code ~= 0 then
            vim.notify("cargo build failed: " .. output.stderr, vim.log.levels.ERROR)
            return command[1]
          end
          opts = {
            command = command[1],
            args = args,
          }
          return command[1]
        end,
        args = function()
          if opts ~= nil then return opts.args end
          return {}
        end,
        cwd = "${workspaceFolder}",
        stopOnEntry = false,
        sourceMap = sourceMapping,
        preRunCommands = get_scripts(codelldb_path, "rust"),
      },
    }
  end,
}
