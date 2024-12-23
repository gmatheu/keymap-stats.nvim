local M = {}

function M.stats()
  local stats = require("keymap-stats").stats
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "Keymap Stats",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
  })

  popup:mount()
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local content = vim.split(vim.inspect(stats), "\n")
  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, content)
  vim.api.nvim_win_set_cursor(popup.winid, { 1, 0 })
  vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
end

function M.session()
  local session_state = require("keymap-stats.api").state.session
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local popup = Popup({
    enter = true,
    focusable = true,
    border = {
      style = "rounded",
      text = {
        top = "Keymap Usage Stats (Session)",
        top_align = "center",
      },
    },
    position = "50%",
    size = {
      width = "80%",
      height = "80%",
    },
  })

  popup:mount()
  popup:on(event.BufLeave, function()
    popup:unmount()
  end)

  local sorted_stats = {}
  for key, count in pairs(session_state.keymap_count) do
    table.insert(sorted_stats, { key = key, count = count })
  end

  table.sort(sorted_stats, function(a, b)
    return a.count > b.count
  end)

  local lines = {}
  local max_keymap_width = 6 -- "Keymap" length
  local max_count_width = 5 -- "Count" length

  -- Find max widths
  for _, stat in ipairs(sorted_stats) do
    max_keymap_width = math.max(max_keymap_width, #stat.key)
    max_count_width = math.max(max_count_width, #tostring(stat.count))
  end

  -- Create header
  local header = string.format("| %-" .. max_keymap_width .. "s | %-" .. max_count_width .. "s |", "Keymap", "Count")
  table.insert(lines, header)
  table.insert(
    lines,
    "|" .. string.rep("-", max_keymap_width + 2) .. "|" .. string.rep("-", max_count_width + 2) .. "|"
  )

  -- Add data rows
  for _, stat in ipairs(sorted_stats) do
    local row = string.format("| %-" .. max_keymap_width .. "s | %" .. max_count_width .. "d |", stat.key, stat.count)
    table.insert(lines, row)
  end

  vim.api.nvim_buf_set_lines(popup.bufnr, 0, -1, false, lines)
  vim.api.nvim_win_set_cursor(popup.winid, { 1, 0 })
  vim.api.nvim_buf_set_option(popup.bufnr, "modifiable", false)
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
