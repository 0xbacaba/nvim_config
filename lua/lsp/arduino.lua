return {
  setup = function(default_config)
    local lspconfig = require "lspconfig"
    lspconfig.arduino_language_server.setup(vim.tbl_deep_extend("force", default_config, {
      autostart = false,
      on_new_config = function(config, _)
        config.capabilities.textDocument.semanticTokens = vim.NIL
        config.capabilities.workspace.semanticTokens = vim.NIL

        config.settings = {
          clangd = {
            "--completion-style=detailed",
          },
        }
      end,
      root_dir = lspconfig.util.root_pattern("sketch.yaml", "*.ino", "*.pde"),
      filetypes = { "arduino", "cpp", "c", "ino", "pde", "h" },
      cmd = {
        "arduino-language-server",
        "-cli-config",
        os.getenv "ARDUINO_CONFIG_FILE"
          or ((os.getenv "ARDUINO_DIRECTORIES_DATA" or "~/.arduino15") .. "/arduino-cli.yaml"),
      },
    }))
  end,
}
