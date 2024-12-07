local keybind_descs = {
  run_selection = "Execute selection",
  run_line = "Execute line",
  run_cell = "Run cell",
  run_cell_and_above = "Run cell and above",
  run_all = "Run all",
  show_output = "Show output",
  hide_output = "Hide output",
  delete_cell = "Delete cell",
}

local keybind_util = require "utils.keybinds"
local keybinds = {
  { keybind_descs.run_selection, "<leader>me", keybind_util.mapmode.visual, "<ESC>:MoltenEvaluateVisual<CR>gv" },
  { keybind_descs.run_line, "<leader>me", keybind_util.mapmode.normal, ":MoltenEvaluateLine<CR>" },
  { keybind_descs.run_cell, "<leader>mr", keybind_util.mapmode.normal, ":MoltenReevaluateCell<CR>" },
  { keybind_descs.run_all, "<leader>mR", keybind_util.mapmode.normal, ":MoltenReevaluateAll<CR>" },
  { keybind_descs.show_output, "<leader>mo", keybind_util.mapmode.normal, ":MoltenShowOutput<CR>" },
  { keybind_descs.hide_output, "<leader>mh", keybind_util.mapmode.normal, ":MoltenHideOutput<CR>" },
  { keybind_descs.delete_cell, "<leader>md", keybind_util.mapmode.normal, ":MoltenDelete<CR>" },
}

return {
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    version = "^1.0.0",
    init = function()
      vim.g.molten_output_win_max_height = 20
      vim.g.molten_auto_open_output = false
      vim.g.molten_wrap_output = true
      vim.g.molten_virt_text_output = true
      vim.g.molten_virt_lines_off_by_1 = true
    end,
    config = function()
      local utils = require "utils.pyvenv"
      utils.pip_install_needed { "pynvim", "jupyter_client", "nbformat" }

      keybind_util.set_keybinds(keybinds)
    end,
  },
  {
    "quarto-dev/quarto-nvim",
    dependencies = {
      "jmbuhr/otter.nvim",
      "benlubas/molten-nvim",
    },
    ft = { "quarto", "markdown" },
    config = function()
      local quarto = require "quarto"
      quarto.setup {
        lspFeatures = {
          languages = { "python" },
          chunks = "all",
          diagnostics = {
            enabled = true,
            triggers = { "BufWritePost" },
          },
          completion = {
            enabled = true,
          },
        },
        keymap = {
          hover = keybind_util.keybinds.lsp.hover[2],
          definition = keybind_util.keybinds.lsp.definition[2],
        },
        codeRunner = {
          enabled = true,
          default_method = "molten",
        },
      }
      quarto.activate()

      local runner = require "quarto.runner"
      local runner_map = {
        [keybind_descs.run_selection] = runner.run_range,
        [keybind_descs.run_line] = runner.run_line,
        [keybind_descs.run_cell] = runner.run_cell,
        [keybind_descs.run_all] = function() runner.run_all(true) end,
      }
      local quarto_keybinds = {
        { keybind_descs.run_cell_and_above, "<leader>ma", keybind_util.mapmode.normal, runner.run_above },
      }
      for _, v in ipairs(keybinds) do
        ---@diagnostic disable-next-line: assign-type-mismatch
        v[4] = runner_map[v[1]]
        if v[4] ~= nil then table.insert(quarto_keybinds, v) end
      end
      keybind_util.set_keybinds(quarto_keybinds)
    end,
  },
}
