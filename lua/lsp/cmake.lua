return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"
    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = { "neocmakelsp", "stdio" },
      filetypes = { "cmake" },
      root_dir = lspconfig.util.root_pattern ".git",
      single_file_support = true,
      init_options = {
        format = {
          enable = true,
        },
        lint = {
          enable = true,
        },
        scan_cmake_in_package = true,
      },
    })

    lspconfig.neocmake.setup(config)
  end,
}
