local api = require("keymap-stats.api")
local M = {}
local state = {
  instrumented = false,
}
local stats = {}

local count = api.count
local count_keymap = api.count_keymap

local function instrument_which_key(_count, _count_keymap, notify, opts)
  local wk = require("which-key")
  local wk_view = require("which-key.view")
  local wk_util = require("which-key.util")
  local _execute = wk_view.execute
  local _show = wk.show

  local function execute(prefix_i, mode, buf)
    count_keymap(prefix_i, mode, "which-key", notify)
    _execute(prefix_i, mode, buf)
  end

  local function show(keys, o)
    local notation = vim.inspect(wk_util.parse_keys(keys).notation)
    count(notation, "n", "which-key", notify, "which-key-window")
    _show(keys, o)
  end
  wk_view.execute = execute
  wk.show = show
end

M.setup = instrument_which_key
M.stats = stats
M.state = state

return M
