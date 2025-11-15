return {
  "GCBallesteros/jupytext.nvim",
  dependencies = {
    "quarto-dev/quarto-nvim",
  },
  config = function()
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
