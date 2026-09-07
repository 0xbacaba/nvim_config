return {
  {
    "iamcco/markdown-preview.nvim",
    cmd = { "MarkdownPreviewToggle", "MarkdownPreview", "MarkdownPreviewStop" },
    ft = { "markdown" },
    build = function()
      vim.opt.rtp:prepend(vim.fn.stdpath "data" .. "/lazy/markdown-preview.nvim")
      vim.fn["mkdp#util#install"]()
    end,
    config = function()
      vim.g.mkdp_auto_start = 1
      vim.g.mkdp_auto_close = 0
      vim.g.mkdp_preview_options = {
        mkit = {},
        katex = {},
        uml = {},
        maid = {},
        sequence_diagrams = {},
        flowchart_diagrams = {},
        disable_sync_scroll = 0,
      }
      vim.g.mkdp_theme = "dark"

      vim.api.nvim_create_autocmd("Filetype", {
        pattern = "markdown",
        callback = function(args)
          local buftype = vim.bo[args.buf].buftype
          if buftype == "" then vim.cmd "MarkdownPreview" end
        end,
      })
    end,
  },
}
