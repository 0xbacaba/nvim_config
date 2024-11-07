local highlight_overrides = {
  { name = "Comment", value = { fg = "#b9b9b9" } },
  { name = "SpecialComment", value = { fg = "#9b9b9b" } },
}

return {
  apply_color_overrides = function()
    for _, override in ipairs(highlight_overrides) do
      vim.api.nvim_set_hl(0, override.name, override.value)
    end
  end,
}
