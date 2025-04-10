local commands = {
  report = require("keymap-stats.report").report,
  stats = require("keymap-stats.report").stats,
  session = require("keymap-stats.report").session,
  state = require("keymap-stats.report").state,
  clear_state = require("keymap-stats").clear_state,
  clear_log = require("keymap-stats.log").truncate,
}

local M = {}

function M.setup()
  vim.api.nvim_create_user_command("KeymapStats", function(args)
    if commands[args.args] then
      commands[args.args]()
    end
  end, {
    nargs = 1,
    complete = function()
      return { "report", "stats", "session", "state", "clear_state", "clear_log" }
    end,
  })
end

return M
