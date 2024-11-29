--- @param username string
--- @return boolean
local function is_valid(username) return username ~= nil and username ~= "" end

--- Sets the username and tries to save it to a file
--- returns nil if successful, error message if not
--- @param username string
--- @return string | nil
local function set_username(username)
  if not is_valid(username) then return "Invalid username" end

  vim.g.instant_username = username

  local utils = require "utils.data"
  local flag_dir = utils.get_flag_dir()
  local username_file = flag_dir .. "/instant_username"

  local status = vim.fn.writefile({ username }, username_file)
  if status == 0 then return nil end

  return "Failed to write to file"
end

--- Gets the instant username currently set, or the one saved in the flag file.
--- Returns an empty string if no valid username was found.
--- @return string
local function get_username()
  if is_valid(vim.g.instant_username) then return vim.g.instant_username end

  local utils = require "utils.data"
  local username_file = utils.get_flag_dir() .. "/instant_username"

  if vim.fn.filereadable(username_file) == 1 then return vim.fn.readfile(username_file)[1] end

  return ""
end

--- Asks the user for a username. Will only return a valid username or an empty string.
--- @return string
local function ask_username()
  local pc_username = vim.fn.system "whoami"
  local prev_username = get_username()

  local default_username = pc_username
  if not is_valid(prev_username) then default_username = prev_username end

  local username = vim.fn.input("Instant-Username: ", default_username)
  username = string.gsub(username, "\\s*", "")

  return username
end

local function add_command_override(command)
  local overwritten = vim.api.nvim_get_commands({ builtin = false })[command]

  vim.api.nvim_create_user_command(command, function(args)
    local username = get_username()
    if not is_valid(username) then
      username = ask_username()
      if not set_username(username) then vim.notify("Couldn't set Instant-Username", vim.log.levels.WARN) end
    end

    if vim.g.instant_username ~= "" then
      -- definition is in form: call instant#Function(<f-args>)
      local func = overwritten.definition:match "^call%s+([^()]+)"

      -- func is in form instant#Function
      vim.fn[func](unpack(args.fargs))
    else
      vim.notify("Instant-Username not set", vim.log.levels.ERROR)
    end
  end, {
    nargs = overwritten.nargs,
    complete = overwritten.complete,
    bang = overwritten.bang,
    range = overwritten.range,
    count = overwritten.count,
  })
end

return {
  {
    "jbyuki/instant.nvim",
    config = function()
      local username = get_username()
      if is_valid(username) then vim.g.instant_username = username end

      local command_overrides = {
        "InstantStartSingle",
        "InstantJoinSingle",
        "InstantStartSession",
        "InstantJoinSession",
      }

      for _, cmd in ipairs(command_overrides) do
        add_command_override(cmd)
      end

      vim.api.nvim_create_user_command("InstantShare", function(args)
        local address = args.fargs[1]
        local port = args.fargs[2]

        if address == nil then address = "0.0.0.0" end
        if port == nil then port = 8080 end

        vim.cmd("InstantStartServer " .. address .. " " .. port)
        vim.cmd("InstantStartSession 127.0.0.1 " .. port)
      end, { nargs = "*" })
      vim.api.nvim_create_user_command("InstantSetUsername", function(args)
        local name = args.fargs[1]
        if not is_valid(name) then
          name = ask_username()

          if not is_valid(name) then print "Invalid username" end
        end

        local status = set_username(name)
        if status == nil then
          print("Username set: " .. get_username())
        else
          print("Failed to set username: " .. status)
        end
      end, { nargs = "*" })
    end,
  },
}
