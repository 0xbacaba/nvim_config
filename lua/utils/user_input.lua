------------------------------------
--- user input utility functions ---
------------------------------------

---@param tree table
local function calculate_min_width(tree)
  if type(tree) == "string" then return tree:len() end

  local width = 0
  for k, v in pairs(tree) do
    if type(k) == "string" then
      width = math.max(width, k:len(), calculate_min_width(tree[k]))
    elseif type(v) == "string" then
      width = math.max(width, v:len())
    end
  end
  return width
end
local function calculate_min_height(tree)
  local height = 0
  local n = 0
  for _, v in pairs(tree) do
    if type(v) == "table" then height = math.max(height, calculate_min_height(v)) end
    n = n + 1
  end
  return math.max(height, n)
end

return {
  ---@param title string
  ---@param selection_tree table
  ---@param callback function
  show_selection_dialog = function(title, selection_tree, callback)
    local buf = vim.api.nvim_create_buf(false, true)

    local width = vim.go.columns
    local height = vim.go.lines
    local winwidth = math.max(calculate_min_width(selection_tree), title:len() + 2) + 4
    local winheight = calculate_min_height(selection_tree)

    local win = vim.api.nvim_open_win(buf, false, {
      relative = "win",
      style = "minimal",
      title = title,
      title_pos = "center",
      border = "rounded",
      width = winwidth,
      height = winheight,
      col = math.ceil((width - winwidth) / 2),
      row = math.ceil((height - winheight) / 2),
    })
    vim.api.nvim_set_current_win(win)

    local selection_path = {}
    local function show_selection()
      local current_selection = selection_tree
      if current_selection == nil then return end
      for _, v in ipairs(selection_path) do
        current_selection = current_selection[v]
        if current_selection == nil then
          callback(selection_path[#selection_path])
          vim.api.nvim_win_close(win, false)
          return
        end
      end

      local keys = {}
      local values = {}
      local actual_selection = values
      for k, v in pairs(current_selection) do
        if type(k) ~= "number" then actual_selection = keys end

        table.insert(keys, k)
        table.insert(values, v)
      end

      vim.api.nvim_buf_set_lines(buf, 0, -1, false, actual_selection)
    end
    show_selection()
    local function select_option()
      local line = vim.api.nvim_get_current_line()
      table.insert(selection_path, line)
      show_selection()
    end

    vim.keymap.set("n", "<CR>", select_option, { buffer = buf, noremap = false, silent = true })
  end,
}
