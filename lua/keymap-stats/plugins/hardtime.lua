local M = {}

local function instrument_hardtime(count, count_keymap, notify) local hardtime = require "hardtime" end

M.setup = instrument_hardtime

return M
