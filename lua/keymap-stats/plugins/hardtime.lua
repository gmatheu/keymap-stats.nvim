local M = {}
local state = {
  instrumented = false,
}
local stats = {}

--luacheck: ignore 212 unused argument
local function instrument_hardtime(_count, _count_keymap, notify, opts)
  local hardtime = require("hardtime")
  hardtime.disable()
  hardtime.enable()
  state.instrumented = true
end

M.setup = instrument_hardtime
M.state = state
M.stats = stats

return M
