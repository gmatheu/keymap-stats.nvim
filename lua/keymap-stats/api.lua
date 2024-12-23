local log = require("keymap-stats.log")

local M = {}
local state = {
  plugin_name = "keymaps-stats",
  session = {
    keymap_count = {},
  },
}
local function count(lhs, mode, action, notify, type, noremap)
  noremap = noremap or false
  notify = notify or false
  action = action or "default"
  type = type or "keymap"

  lhs = vim.api.nvim_replace_termcodes(lhs, true, true, true)
  local template = "Executed lhs:%s mode:%s action:%s type:%s noremap:%s"

  local key = string.format("%s:%s:%s:%s:%s", lhs, mode, action, type, tostring(noremap))

  -- Let's not count 'key' containing 'S(<any text>)' AI!
  state.session.keymap_count[key] = (state.session.keymap_count[key] or 0) + 1

  log.info(string.format(template, lhs, mode, action, type, noremap))
  if notify then
    local message = string.format("%s executed [%s]: %s", type, action, lhs)
    vim.notify(message, vim.log.levels.INFO, { title = state.plugin_name })
  end
end

local function count_keymap(lhs, mode, action, notify, noremap)
  count(lhs, mode, action, notify, "keymap", noremap)
end

M.count = count
M.count_keymap = count_keymap
M.state = state

return M
