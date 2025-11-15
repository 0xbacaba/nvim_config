return {
  "PlatyPew/jupytext.nvim",
  dependencies = {
    "quarto-dev/quarto-nvim",
  },
  config = function()
    local utils = require "utils.pyvenv"
    utils.pip_install_needed { "jupytext", "ipython", "ipykernel" }
    require("jupytext").setup {
      style = "hydrogen",
      output_extension = "auto",
      force_ft = nil,
      custom_language_formatting = {
        python = {
          extension = "qmd",
          style = "quarto",
          force_ft = "quarto",
        },
      },
    }
  end,
}
