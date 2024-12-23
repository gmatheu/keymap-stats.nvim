local M = {}

--luacheck: ignore 212 unused argument
local function instrument_hardtime(count, count_keymap, notify)
  -- local hardtime = require("hardtime")
end

M.setup = instrument_hardtime
M.stats = {}

return M
