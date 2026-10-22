return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      cmd = { "neocmakelsp", "stdio" },
      filetypes = { "cmake" },
      root_markers = { ".git", ".cmake-format.py" },
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

    vim.lsp.config("neocmake", config)
    vim.lsp.enable "neocmake"
  end,
}
