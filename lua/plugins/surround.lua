return {
  {
    "kylechui/nvim-surround",
    version = "*",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        keymaps = {
          insert = "<leader>si",
          insert_line = "<leader>sI",
          normal = "<leader>san",
          normal_cur = "<leader>sac",
          normal_line = "<leader>saN",
          normal_cur_line = "<leader>saC",
          visual = "<leader>sa",
          visual_line = "<leader>sA",
          delete = "<leader>sd",
          change = "<leader>sc",
          change_line = "<leader>sC",
        },
      }
      require("which-key").add {
        { "<leader>s", group = "󱃸 surround", mode = { "n", "v" } },
        { "<leader>sa", group = " add" },
      }
    end,
  },
}
