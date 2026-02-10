local log = require("keymap-stats.log")

local M = {}
local state = {
  plugin_name = "keymaps-stats",
  session = {
    keymap_count = {},
  },
}
local function count(lhs, mode, action, notify, type, noremap, cnt)
  noremap = noremap or false
  notify = notify or false
  action = action or "default"
  type = type or "keymap"
  cnt = cnt or 1

  lhs = vim.api.nvim_replace_termcodes(lhs, true, true, false)
  local template = "Executed lhs:%s: mode:%s: action:%s: type:%s: noremap:%s: count:%s:"

  local key = string.format("%s:%s:%s:%s:%s", lhs, mode, action, type, tostring(noremap))

  -- Skip counting keys containing 'S(<any text>)'
  if not string.match(key, "S%(.*%)") then
    state.session.keymap_count[key] = (state.session.keymap_count[key] or 0) + cnt
  end

  log.info(string.format(template, lhs, mode, action, type, noremap, cnt))
  if notify then
    local message = string.format("%s executed [%s]: %s (x%d)", type, action, lhs, cnt)
    vim.notify(message, vim.log.levels.INFO, { title = state.plugin_name })
  end
end

local function count_keymap(lhs, mode, action, notify, noremap, cnt)
  count(lhs, mode, action, notify, "keymap", noremap, cnt)
end

M.count = count
M.count_keymap = count_keymap
M.state = state

return M
