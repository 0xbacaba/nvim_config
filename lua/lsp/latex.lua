local function get_forwardsearch_config()
  local uname = vim.fn.system("uname"):gsub("\n", "")
  if uname == "Darwin" then
    -- Only Skim is supported on macOS
    local skim_executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"
    if vim.fn.executable(skim_executable) then
      return {
        executable = skim_executable,
        args = { "-r", "-g", "%l", "%p", "%f" },
      }
    end
  elseif uname == "Linux" then
    local viewer = vim.fn.system("xdg-mime query default application/pdf"):gsub("\n", "")

    if viewer == "okular.desktop" then
      return {
        executable = "okular",
        args = { "--unique", "file:%p#src:%l%f" },
      }
    end

    print "Unsupported pdf viewer for synctex"
  end
  return {}
end

return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      settings = {
        texlab = {
          build = {
            args = { "-synctex=1", "%f" },
            executable = "pdflatex",
            forwardSearchAfter = true,
            onSave = true,
          },
          forwardSearch = get_forwardsearch_config(),
        },
      },
    })

    require("lspconfig").texlab.setup(config)
  end,
}
