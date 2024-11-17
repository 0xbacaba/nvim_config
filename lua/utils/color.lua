local highlight_overrides = {
  { name = "Comment", value = { fg = "#0077aa" } },
  { name = "SpecialComment", value = { fg = "#0066bb" } },
}

return {
  apply_color_overrides = function()
    for _, override in ipairs(highlight_overrides) do
      vim.api.nvim_set_hl(0, override.name, override.value)
    end
  end,
}
