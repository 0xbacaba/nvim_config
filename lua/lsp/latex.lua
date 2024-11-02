local function get_forwardsearch_config()
  local uname = vim.fn.system("uname"):gsub("\n", "")
  if uname == "Darwin" then
    -- Only Skim is supported on macOS
    local skim_executable = "/lpplications/Skim.app/Contents/SharedSupport/displayline"
    if vim.fn.executable(skim_executable) == 1 then
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

local function check_skim()
  local skim_executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"

  if vim.fn.executable(skim_executable) == 0 then
    local utils = require "utils"
    local flag_file = utils.get_flag_dir() .. "/skim_install"
    if vim.fn.filereadable(flag_file) ~= 1 then
      vim.fn.writefile({}, flag_file)

      local should_install = vim.fn.confirm("Skim is not installed. Install now?", "&Yes\n&No", 1)
      if should_install ~= 1 then return end
      utils.ask_to_run("brew install skim", function(succeeded)
        if succeeded then
          vim.notify "Installation successful"
        else
          vim.notify("Installation failed", vim.log.levels.ERROR)
        end
      end)
    end
  end
end

return {
  setup = function(default_config)
    local config = vim.tbl_deep_extend("force", default_config, {
      on_attach = function()
        local uname = vim.fn.system("uname"):gsub("\n", "")
        if uname == "Darwin" then check_skim() end
      end,
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
