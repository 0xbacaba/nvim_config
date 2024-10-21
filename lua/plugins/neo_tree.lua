return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup {
        filesystem = {
          follow_current_file = true,
          group_empty_dirs = true,
          renderers = {
            directory = {
              { "indent" },
              { "icon" },
              {
                "name",
                -- Function that will collapse directories with only one subdirectory
                content = function(_, node, _)
                  local names = {}
                  local current = node

                  -- Traverse directories with only one child and accumulate names
                  while
                    current.type == "directory"
                    and #current.children == 1
                    and current.children[1].type == "directory"
                  do
                    table.insert(names, current.name)
                    current = current.children[1]
                  end

                  if #names > 0 then
                    table.insert(names, current.name)
                    return table.concat(names, "/")
                  else
                    return node.name
                  end
                end,
              },
            },
          },
        },
      }
    end,
  },
}
