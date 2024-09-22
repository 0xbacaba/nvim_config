local function detect_jdks()
  local jdks = {}
  local uname = vim.fn.system("uname"):gsub("\n", "")
  print(uname)

  -- macOS: use /usr/libexec/java_home to detect installed JDKs
  if uname == "Darwin" then
    local handle = io.popen "/usr/libexec/java_home -V 2>&1"
    if handle == nil then
      vim.notify("couldn't detect jdks", vim.log.levels.WARN)
      return {}
    end

    local result = handle:read "*a"
    handle:close()

    local lines = {}
    for line in result:gmatch "[^\r\n]+" do
      table.insert(lines, line)
    end

    -- Remove first line (header) and last line (default JDK path)
    table.remove(lines, 1)
    table.remove(lines, #lines)

    -- Parse lines to extract version and path
    for _, line in ipairs(lines) do
      local version, path = line:match "(%d+)[^/]*(/%S+/Contents/Home)"
      if version and path then
        print("found jdk for version " .. version .. ": " .. path)
        table.insert(jdks, {
          name = "JavaSE-" .. version,
          path = path,
        })
      end
    end

    -- Linux: scan common JDK install paths
  elseif uname == "Linux" then
    local jdk_paths = { "/usr/lib/jvm", "/usr/java" }

    for _, jdk_dir in ipairs(jdk_paths) do
      local handle = io.popen("find " .. jdk_dir .. " -maxdepth 3 -type f -name javac -exec dirname {} \\;")
      if handle == nil then
        vim.notify("couldn't detect jdks", vim.log.levels.WARN)
        return {}
      end

      for line in handle:lines() do
        local version = line:match "java%-(%d+)%-"
        local path = line:gsub("/bin$", "")
        print("found jdk for version " .. version .. ": " .. path)
        table.insert(jdks, {
          name = "JavaSE-" .. version,
          path = path,
        })
      end
      handle:close()
    end
  end

  return jdks
end

local home = os.getenv "HOME"
local xdg_data_home = os.getenv "XDG_DATA_HOME" or home .. "/.local/share"
local function find_nvim_data()
  local default = home .. "/.local/share/nvim"
  local potential_paths = {
    xdg_data_home and (xdg_data_home .. "/nvim"),
    default,
  }

  for _, path in ipairs(potential_paths) do
    if vim.fn.isdirectory(path) then return path end
  end

  vim.notify("could not find nvim data directory. will default to " .. default, vim.log.levels.WARN)
  return default
end

local nvim_data = find_nvim_data()

local function get_config()
  local common = nvim_data .. "/mason/packages/jdtls/config_"
  local uname = vim.fn.system("uname"):gsub("\n", "")
  local arch = vim.fn.system("uname", "-m"):gsub("\n", "")

  local os
  if uname == "Linux" then
    os = common .. "linux"
  elseif uname == "Darwin" then
    os = common .. "mac"
  end

  if arch:match "(aarch)|(arm)" ~= "" then return os .. "_arm" end

  return os
end

return {
  setup = function()
    local jdtls = require "jdtls"
    local lspconfig = require "lspconfig"

    -- File types that signify a Java project's root directory. This will be
    -- used by eclipse to determine what constitutes a workspace
    local root_markers = { "gradlew", "mvnw", ".git", "pom.xml", ".classpath" }
    local root_dir = require("jdtls.setup").find_root(root_markers)

    -- eclipse.jdt.ls stores project specific data within a folder. If you are working
    -- with multiple different projects, each project must use a dedicated data directory.
    -- This variable is used to configure eclipse to use the directory name of the
    -- current project found using the root_marker as the folder for project specific data.
    local workspace_folder = xdg_data_home .. "/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    local bundles = {
      vim.fn.glob(
        nvim_data .. "/mason/packages/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar"
      ),
    }

    -- The on_attach function is used to set key maps after the language server
    -- attaches to the current buffer
    local on_attach = function(client, bufnr)
      require("jdtls").setup_dap { hotcodereplace = "auto", config_overrides = {} }

      -- Regular Neovim LSP client keymappings
      local utils = require "utils"
      utils.set_lsp_keybinds(client, bufnr)

      -- Java extensions provided by jdtls
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      utils.nnoremap("<C-o>", jdtls.organize_imports, bufopts, "Organize imports")
      utils.nnoremap("<leader>lev", jdtls.extract_variable, bufopts, "Extract variable")
      utils.nnoremap("<leader>lec", jdtls.extract_constant, bufopts, "Extract constant")
      utils.vnoremap(
        "<leader>em",
        [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]],
        bufopts,
        "Extract method"
      )
    end

    local config = {
      flags = {
        debounce_text_changes = 80,
      },
      on_attach = on_attach, -- We pass our on_attach keybindings to the configuration map
      root_dir = lspconfig.util.root_pattern(table.unpack(root_markers)), -- Set the root directory to our found root_marker
      init_options = {
        bundles = bundles,
      },
      -- Here you can configure eclipse.jdt.ls specific settings
      -- These are defined by the eclipse.jdt.ls project and will be passed to eclipse when starting.
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {
          format = {
            settings = {
              -- Use Google Java style guidelines for formatting
              -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
              -- and place it in the ~/.local/share/eclipse directory
              url = xdg_data_home .. "/eclipse/eclipse-java-google-style.xml",
              profile = "GoogleStyle",
            },
          },
          signatureHelp = { enabled = true },
          contentProvider = { preferred = "fernflower" }, -- Use fernflower to decompile library code
          -- Specify any completion options
          completion = {
            favoriteStaticMembers = {
              "org.hamcrest.MatcherAssert.assertThat",
              "org.hamcrest.Matchers.*",
              "org.hamcrest.CoreMatchers.*",
              "org.junit.jupiter.api.Assertions.*",
              "java.util.Objects.requireNonNull",
              "java.util.Objects.requireNonNullElse",
              "org.mockito.Mockito.*",
            },
            filteredTypes = {
              "com.sun.*",
              "io.micrometer.shaded.*",
              "java.awt.*",
              "jdk.*",
              "sun.*",
            },
          },
          -- Specify any options for organizing imports
          sources = {
            organizeImports = {
              starThreshold = 9999,
              staticStarThreshold = 9999,
            },
          },
          -- How code generation should act
          codeGeneration = {
            toString = {
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            hashCodeEquals = {
              useJava7Objects = true,
            },
            useBlocks = true,
          },
          -- If you are developing in projects with different Java versions, you need
          -- to tell eclipse.jdt.ls to use the location of the JDK for your Java version
          -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
          -- And search for `interface RuntimeOption`
          -- The `name` is NOT arbitrary, but must match one of the elements from `enum ExecutionEnvironment` in the link above
          configuration = {
            runtimes = detect_jdks(),
          },
        },
      },
      -- cmd is the command that starts the language server. Whatever is placed
      -- here is what is passed to the command line to execute jdtls.
      -- Note that eclipse.jdt.ls must be started with a Java version of 17 or higher
      -- See: https://github.com/eclipse/eclipse.jdt.ls#running-from-the-command-line
      -- for the full list of options
      cmd = {
        "java",
        "-Declipse.application=org.eclipse.jdt.ls.core.id1",
        "-Dosgi.bundles.defaultStartLevel=4",
        "-Declipse.product=org.eclipse.jdt.ls.core.product",
        "-Dlog.protocol=true",
        "-Dlog.level=ALL",
        "-Xmx4g",
        "--add-modules=ALL-SYSTEM",
        "--add-opens",
        "java.base/java.util=ALL-UNNAMED",
        "--add-opens",
        "java.base/java.lang=ALL-UNNAMED",
        -- If you use lombok, download the lombok jar and place it in ~/.local/share/eclipse
        -- "-javaagent:"
        --   .. home
        --   .. "/.local/share/eclipse/lombok.jar",

        -- The jar file is located where jdtls was installed. This will need to be updated
        -- to the location where you installed jdtls
        "-jar",
        vim.fn.glob(nvim_data .. "/mason/packages/jdtls/plugins/org.eclipse.equinox.launcher_*.jar"),

        -- The configuration for jdtls is also placed where jdtls was installed. This will
        -- need to be updated depending on your environment
        "-configuration",
        get_config(),

        -- Use the workspace_folder defined above to store data for this project
        "-data",
        workspace_folder,
      },
    }

    -- Finally, start jdtls. This will run the language server using the configuration we specified,
    -- setup the keymappings, and attach the LSP client to the current buffer
    lspconfig.jdtls.setup(config)
  end,
}
