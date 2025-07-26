local utils = require "utils"
local arduino = require "utils.arduino"

return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"

    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = { "clangd", "--completion-style=detailed" },
      on_attach = function(client, bufnr)
        local bufopts = { noremap = true, silent = true, buffer = bufnr }
        utils.set_lsp_keybinds(client, bufnr)

        local neotest = require "neotest"
        utils.nmap("<leader>dt", function() neotest.run.run(vim.fn.expand "%") end, bufopts, "Test File")
        utils.nmap("<leader>dT", neotest.run.run, bufopts, "Test")
        utils.nmap("<leader>dS", neotest.summary.toggle, bufopts, "Toggle Test Summary")

        ---@param list table<string>
        ---@param pattern string
        local listHas = function(list, pattern)
          for _, flag in ipairs(list) do
            if flag:match(pattern) then return true end
          end
          return false
        end

        -- use compile_commands in project directory if available
        local compile_commands = client.config.root_dir .. "/compile_commands.json"
        if
          vim.fn.filereadable(compile_commands) == 1 and not listHas(client.config.cmd, "^%-%-compile%-commands%-dir=")
        then
          vim.list_extend(client.config.cmd, { "--compile-commands-dir=" .. client.config.root_dir })
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
      end,
      root_dir = lspconfig.util.root_pattern(
        "sketch.yaml", -- arduino-specific
        "*.ino",

        ".git", -- general
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
