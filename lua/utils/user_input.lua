------------------------------------
--- user input utility functions ---
------------------------------------

return {
  ---@param title string
  ---@param selection_tree table
  ---@param callback function
  show_selection_tree = function(title, selection_tree, callback)
    local selection_path = {}

    local function show_selection()
      local current_selection = selection_tree
      if current_selection == nil then return end
      for _, v in ipairs(selection_path) do
        current_selection = current_selection[v]
        if current_selection == nil then
          callback(selection_path[#selection_path])
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

      vim.ui.select(actual_selection, { prompt = title }, function(choice)
        table.insert(selection_path, choice)
        show_selection()
      end)
    end
    show_selection()
  end,
}
