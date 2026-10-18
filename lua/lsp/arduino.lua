return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      autostart = false,
      on_new_config = function(newconfig, _)
        newconfig.capabilities.textDocument.semanticTokens = vim.NIL
        newconfig.capabilities.workspace.semanticTokens = vim.NIL

        newconfig.settings = {
          clangd = {
            "--completion-style=detailed",
          },
        }
      end,
      root_markers = { "sketch.yaml", "*.ino", "*.pde" },
      filetypes = { "arduino", "cpp", "c", "ino", "pde", "h" },
      cmd = {
        "arduino-language-server",
        "-cli-config",
        os.getenv "ARDUINO_CONFIG_FILE"
          or ((os.getenv "ARDUINO_DIRECTORIES_DATA" or "~/.arduino15") .. "/arduino-cli.yaml"),
      },
    })
    vim.lsp.config("arduino_language_server", config)
    vim.lsp.enable "arduino_language_server"
  end,
}
