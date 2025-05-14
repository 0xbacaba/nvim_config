local utils = require "utils"
local function get_highest_jdk(all_jdks)
  local max_version = 0
  local max_version_index = -1
  for i, jdk in ipairs(all_jdks) do
    local version = tonumber(jdk.name:match "(%d+)")
    if version ~= nil then
      if version > max_version then
        max_version = version
        max_version_index = i
      end
    end
  end
  return all_jdks[max_version_index]
end
local function detect_jdks()
  local jdks = {}
  local uname = utils.get_uname()

  -- macOS: use /usr/libexec/java_home to detect installed JDKs
  if uname == utils.OS.macos then
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
        table.insert(jdks, {
          name = "JavaSE-" .. version,
          path = path,
        })
      end
    end

    -- Linux: scan common JDK install paths
  elseif uname == utils.OS.linux then
    local jdk_paths = { "/usr/lib/jvm", "/usr/java" }

    for _, jdk_dir in ipairs(jdk_paths) do
      local handle = io.popen("find " .. jdk_dir .. " -maxdepth 3 -type f -name javac -exec dirname {} \\; 2>/dev/null")
      if handle == nil then
        vim.notify("couldn't detect jdks", vim.log.levels.WARN)
        return {}
      end

      for line in handle:lines() do
        local version = line:match "java%-(%d+)%-"
        local path = line:gsub("/bin$", "")
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

local nvim_data = utils.find_nvim_data()
local nvim_cache = utils.find_nvim_cache()
local nvim_lsp_cache = nvim_cache .. "/lsp"

local function get_config()
  local common = nvim_data .. "/mason/packages/jdtls/config_"
  local uname = utils.get_uname()
  local arch = utils.get_architecture()

  local os
  if uname == utils.OS.linux then
    os = common .. "linux"
  elseif uname == utils.OS.macos then
    os = common .. "mac"
  end

  if arch:match "aarch" or arch:match "arm" then return os .. "_arm" end

  return os
end

return {
  setup = function(default_config)
    local jdtls = require "jdtls"
    local lspconfig = require "lspconfig"

    -- File types that signify a Java project's root directory. This will be
    -- used by eclipse to determine what constitutes a workspace
    local root_markers = { "pom.xml", "gradlew", "mvnw", ".git", ".classpath" }
    local root_dir = require("jdtls.setup").find_root(root_markers)

    -- eclipse.jdt.ls stores project specific data within a folder. If you are working
    -- with multiple different projects, each project must use a dedicated data directory.
    -- This variable is used to configure eclipse to use the directory name of the
    -- current project found using the root_marker as the folder for project specific data.
    local workspace_folder = nvim_lsp_cache .. "/eclipse/" .. vim.fn.fnamemodify(root_dir, ":p:h:t")

    local detected_jdks = detect_jdks()
    local bundles = {}

    -- Include java-test bundle
    local java_test_path = require("mason-registry").get_package("java-test"):get_install_path()
    local java_test_bundle = vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n")
    if #java_test_bundle > 0 then vim.list_extend(bundles, java_test_bundle) end

    -- Include java-debug-adapter bundle
    local java_debug_path = require("mason-registry").get_package("java-debug-adapter"):get_install_path()
    local java_debug_bundle =
      vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n")
    if #java_debug_bundle > 0 then vim.list_extend(bundles, java_debug_bundle) end

    local jdtls_install = require("mason-registry").get_package("jdtls"):get_install_path()

    local java_agent = jdtls_install .. "/lombok.jar"
    local launcher_jar = vim.fn.glob(jdtls_install .. "/plugins/org.eclipse.equinox.launcher_*.jar")

    -- The on_attach function is used to set key maps after the language server
    -- attaches to the current buffer
    local on_attach = function(client, bufnr)
      -- Regular Neovim LSP client keymappings
      utils.set_lsp_keybinds(client, bufnr)

      -- Java extensions provided by jdtls
      local bufopts = { noremap = true, silent = true, buffer = bufnr }
      utils.nmap("<leader>lo", jdtls.organize_imports, bufopts, "Organize imports")
      utils.nmap("<leader>lev", jdtls.extract_variable, bufopts, "Extract variable")
      utils.nmap("<leader>lec", jdtls.extract_constant, bufopts, "Extract constant")
      utils.vmap("<leader>em", [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], bufopts, "Extract method")

      -- Unit Test keybinds
      utils.nmap("<leader>dt", jdtls.test_class, bufopts, "Test class")
      utils.nmap("<leader>dT", jdtls.test_nearest_method, bufopts, "Test method")
    end

    local unpack_func = table.unpack or unpack

    local config = vim.tbl_deep_extend("force", default_config, {
      flags = {
        debounce_text_changes = 80,
      },
      on_attach = on_attach, -- We pass our on_attach keybindings to the configuration map
      root_dir = lspconfig.util.root_pattern(unpack_func(root_markers)), -- Set the root directory to our found root_marker
      init_options = {
        bundles = bundles,
      },
      -- Here you can configure eclipse.jdt.ls specific settings
      -- These are defined by the eclipse.jdt.ls project and will be passed to eclipse when starting.
      -- See https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
      -- for a list of options
      settings = {
        java = {
          references = {
            includeDecompiledSources = true,
          },
          eclipse = {
            downloadSources = true,
          },
          maven = {
            downloadSources = true,
          },
          format = {
            settings = {
              -- Use Google Java style guidelines for formatting
              -- To use, make sure to download the file from https://github.com/google/styleguide/blob/gh-pages/eclipse-java-google-style.xml
              -- and place it in the ~/.local/share/eclipse directory
              url = utils.xdg_data_home .. "/eclipse/eclipse-java-google-style.xml",
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
            runtimes = {
              get_highest_jdk(detected_jdks),
            },
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
        "--module-path",
        table.concat(java_test_bundle, ":"),

        "-javaagent:" .. java_agent,

        "-jar",
        launcher_jar,

        "-configuration",
        get_config(),

        -- Use the workspace_folder defined above to store data for this project
        "-data",
        workspace_folder,
      },
    })

    -- Finally, start jdtls. This will run the language server using the configuration we specified,
    -- setup the keymappings, and attach the LSP client to the current buffer
    lspconfig.jdtls.setup(config)
  end,
}
