local commands = {
  report = require("keymap-stats.report").report,
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
      return { "report" }
    end,
  })
end

return M
