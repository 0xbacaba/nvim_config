local utils = require "utils"
local function get_forwardsearch_config()
  local uname = utils.get_uname()
  if uname == utils.OS.macos then
    -- Only Skim is supported on macOS
    local skim_executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"
    if vim.fn.executable(skim_executable) == 1 then
      return {
        executable = skim_executable,
        args = { "-r", "-g", "%l", "%p", "%f" },
      }
    end
  elseif uname == utils.OS.linux then
    local viewer = vim.fn.system("xdg-mime query default application/pdf"):gsub("\n", "")

    if string.find(viewer, "okular") then
      return {
        executable = "okular",
        args = { "--unique", "file:%p#src:%l%f" },
      }
    end

    print("Unsupported pdf viewer for synctex: " .. viewer)
  end
  return {}
end
local function texlab_forward_search()
  -- Get the current buffer and cursor position
  local params = {
    textDocument = vim.lsp.util.make_text_document_params(),
    position = { line = vim.fn.line "." - 1, character = vim.fn.col "." - 1 },
  }
  -- Send the `texlab/forwardSearch` request
  vim.lsp.buf_request(0, "textDocument/forwardSearch", params, function(err)
    if err then vim.notify("Texlab forward search failed: " .. err.message, vim.log.levels.ERROR) end
  end)
end

local function check_skim()
  local skim_executable = "/Applications/Skim.app/Contents/SharedSupport/displayline"

  if vim.fn.executable(skim_executable) == 0 then
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
      on_attach = function(_, bufnr)
        local uname = utils.get_uname()
        if uname == utils.OS.macos then check_skim() end

        -- setup keybinds
        utils.set_lsp_keybinds(nil, bufnr)
        utils.set_keybinds({
          {
            "Show in viewer",
            "<leader>lj",
            utils.mapmode.normal,
            texlab_forward_search,
          },
        }, bufnr)
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
