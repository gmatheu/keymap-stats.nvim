local M = {}

local function instrument_which_key(count, count_keymap, notify)
  local wk = require("which-key")
  local wk_view = require("which-key.view")
  local wk_util = require("which-key.util")
  local _execute = wk_view.execute
  local _show = wk.show

  local function execute(prefix_i, mode, buf)
    count_keymap(prefix_i, mode, "which-key", notify)
    _execute(prefix_i, mode, buf)
  end

  local function show(keys, opts)
    local notation = vim.inspect(wk_util.parse_keys(keys).notation)
    count(notation, "n", "which-key", notify, "which-key-window")
    _show(keys, opts)
  end
  wk_view.execute = execute
  wk.show = show
end

M.setup = instrument_which_key
M.stats = {}

return M
