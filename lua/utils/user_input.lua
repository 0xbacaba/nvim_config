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

      local actual_selection = {}
      for k, v in pairs(current_selection) do
        if type(k) ~= "number" then
          table.insert(actual_selection, k)
        else
          table.insert(actual_selection, v)
        end
      end

      vim.ui.select(actual_selection, { prompt = title }, function(choice)
        if choice == "" or choice == nil then return end
        table.insert(selection_path, choice)
        show_selection()
      end)
    end
    show_selection()
  end,
}
