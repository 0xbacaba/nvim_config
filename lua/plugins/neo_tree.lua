return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    config = function()
      require("neo-tree").setup {
        nesting_rules = {
          ["tex"] = {
            pattern = "(.*)%.tex$",
            files = {
              "%1.aux",
              "%1.log",
              "%1.bib",
              "%1.synctex.gz",
              "%1.fls",
              "%1.fdb_latexmk",
              "%1.bbl",
              "%1.blg",
              "%1.out",
            },
          },
        },
        filesystem = {
          follow_current_file = true,
          group_empty_dirs = true,
          window = {
            mappings = {
              ["O"] = "system_open",
            },
          },
          commands = {
            system_open = function(state)
              local node = state.tree:get_node()
              local path = node:get_id()

              local utils = require "utils"
              local uname = utils.get_uname()

              if uname == utils.OS.macos then
                vim.fn.jobstart({ "open", "-g", path }, { detach = true })
              elseif uname == utils.OS.linux then
                vim.fn.jobstart({ "xdg-open", path }, { detach = true })
              end
            end,
            open = function(state)
              local fs = require "neo-tree.sources.filesystem"
              local fsc = require "neo-tree.sources.filesystem.commands"

              local M = {}
              M.toggle_recursive = function()
                local node = state.tree:get_node()
                fs.toggle_directory(state, node, nil, false, false, function()
                  local children = node:get_child_ids()
                  if #children == 0 then M.toggle_recursive() end
                end)
              end

              local node = state.tree:get_node()
              if node.type == "directory" then
                M.toggle_recursive()
              else
                fsc.open(state)
              end
            end,
          },
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
