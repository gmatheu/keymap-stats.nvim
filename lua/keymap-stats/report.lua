local M = {}

function M.stats()
  local stats = require("keymap-stats").stats
  vim.notify(vim.inspect(stats), "info", { title = "Keymap Stats" })
end

function M.report()
  local file_path = require("keymap-stats.log").file
  local file = io.open(file_path, "r")
  if file == nil then
    print("Error: Unable to open", file_path)
    return
  end

  local hints = {}
  for line in file:lines() do
    if line:find("Executed") then
      local parts = {}
      for part in string.gmatch(line, "%[%w+%]") do
        table.insert(parts, part)
      end
      local lastBracketIndex = string.find(line, "%]([^%]]+)$")
      local lastPart = string.sub(line, lastBracketIndex + 1)

      local hint = lastPart
      -- local hint = string.gsub(line, "%[.-%] ", "")
      hints[hint] = hints[hint] and hints[hint] + 1 or 1
    end
  end
  file:close()

  local sorted_hints = {}
  for hint, count in pairs(hints) do
    table.insert(sorted_hints, { hint, count })
  end

  table.sort(sorted_hints, function(a, b)
    return a[2] > b[2]
  end)

  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "Keymap Usage Stats",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = "70%",
      height = "80%",
    },
  })

  popup:mount()
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  for i, pair in ipairs(sorted_hints) do
    local content = string.format("%d. %s (%d times)", i, pair[1], pair[2])

    vim.api.nvim_buf_set_lines(popup.bufnr, i - 1, i - 1, false, { content })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
  end
end

return M
