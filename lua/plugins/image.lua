local emulators = {
  konsole = "Konsole",
  kitty = "Kitty",
  iterm = "iTerm",
  other = "Other",
}

---@return string|nil
local function get_backend()
  local utils = require "utils"

  local flag = utils.get_flag_dir() .. "/image_backend"
  if vim.fn.filereadable(flag) == 0 then return nil end

  local term = vim.fn.readfile(flag)[1]
  local backends = {
    ueberzug = { emulators.iterm, emulators.other },
    kitty = { emulators.konsole, emulators.kitty },
  }
  for k, v in pairs(backends) do
    if vim.tbl_contains(v, term) then return k end
  end
  return nil
end

---@param backend string
local function set_backend(backend)
  local utils = require "utils"
  local flag_file = utils.get_flag_dir() .. "/image_backend"

  local status_code = vim.fn.writefile({ backend }, flag_file)
  if status_code ~= 0 then
    vim.notify("Couldn't write to image_backend flag file", vim.log.levels.WARN)
    return
  end

  vim.notify "restart to apply changes"
end

return {
  {
    "3rd/image.nvim",
    dependencies = {
      "leafo/magick",
      "nvim-lua/plenary.nvim",
      {
        "vhyrro/luarocks.nvim",
        opts = {
          rocks = {
            hererocks = true,
          },
        },
      },
    },
    build = false,
    config = function()
      vim.api.nvim_create_user_command("ConfigureImageBackend", function()
        local utils = require "utils"
        local uname = utils.get_uname()

        local selection_tree = {
          ["Linux"] = { emulators.konsole, emulators.kitty, emulators.other },
          ["Darwin"] = { emulators.iterm, emulators.kitty, emulators.other },
        }
        utils.show_selection_tree("Select Terminal Emulator", selection_tree[uname], set_backend)
      end, {})

      local backend = get_backend()
      if backend == nil then return end
      if backend == "ueberzug" and vim.fn.executable "ueberzug" == 0 then return end

      require("image").setup {
        backend = backend,
        kitty_method = "normal",
        processor = "magick_rock",
        integrations = {
          markdown = {
            enabled = true,
            sizing_strategy = "auto", -- Options: "auto", "height", "width"
            download_remote_images = true,
            clear_in_insert_mode = true,
            only_render_image_at_cursor = true,
          },
        },
        log_level = "warn", -- Log level for diagnostics: "error", "warn", "info", "debug"
        disable_mouse_events = false,
        max_width = math.huge,
        max_height = math.huge,
        max_width_window_percentage = math.huge,
        max_height_window_percentage = math.huge,
        window_overlap_clear_enabled = false,
        window_overlap_clear_ft_ignore = { "cmp_menu", "cmp_docs", "" },
        editor_only_render_when_focused = false,
        tmux_show_only_in_active_window = false,
        hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.pdf" },
      }
    end,
  },
}
