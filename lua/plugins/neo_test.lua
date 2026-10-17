return {
  {
    "nvim-neotest/neotest",
    lazy = true,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "alfaix/neotest-gtest",
    },
    config = function()
      require("neotest").setup {
        adapters = {
          require("neotest-gtest").setup {},
        },
      }
    end,
  },
}
