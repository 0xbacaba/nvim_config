return {
  "nvim-telescope/telescope.nvim",
  tag = "0.1.8",
  dependencies = {
    "nvim-lua/plenary.nvim",
  },
  config = function()
    require("telescope").setup {
      defaults = {
        file_ignore_patterns = {
          ".*%.o",
          ".*%.class",
          ".*%.aux",
          ".*%.log",
          ".*%.synctex.gz",
          ".*%.fls",
          ".*%.fdb_latexmk",
          ".*%.bbl",
          ".*%.blg",
          ".*%.out",
          ".*%.bcf",
          ".*%.bib.bbl",
          ".*%.bib.blg",
          ".*%.tex.bbl",
          ".*%.tex.blg",
          ".*%.upa",
          ".*%.upb",
          ".*%.run.xml",
          ".*%.toc",
          ".*%.lof",
          ".*%.lot",
          ".*%.dvi",
          ".*%.out.ps",
        },
      },
    }
  end,
}
