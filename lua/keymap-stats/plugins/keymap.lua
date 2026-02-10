local log = require("keymap-stats.log")

local api = require("keymap-stats.api")
local M = {}
local state = {
  instrumented = false,
}
local stats = {
  callback_count = 0,
  rhs_count = 0,
  excluded_rhs_lhs = {},
  included_lhs = {},
  skipped_lhs = {},
}

local count_keymap = api.count_keymap

--- Default Neovim keymaps to instrument
-- These are built-in Neovim behaviors that aren't registered as explicit keymaps
-- Each entry: { lhs = "<key>", mode = "n/v/i", rhs = function or string, desc = "description" }
local default_neovim_mappings = {
  -- Normal mode scrolling
  { lhs = "<C-e>", mode = "n", rhs = "<C-e>", desc = "Scroll down" },
  { lhs = "<C-d>", mode = "n", rhs = "<C-d>", desc = "Scroll down half page" },
  { lhs = "<C-y>", mode = "n", rhs = "<C-y>", desc = "Scroll up" },
  { lhs = "<C-u>", mode = "n", rhs = "<C-u>", desc = "Scroll up half page" },
  { lhs = "<C-f>", mode = "n", rhs = "<C-f>", desc = "Scroll down full page" },
  { lhs = "<C-b>", mode = "n", rhs = "<C-b>", desc = "Scroll up full page" },
  -- Mode switching
  { lhs = "i", mode = "n", rhs = "i", desc = "Insert mode" },
  { lhs = "a", mode = "n", rhs = "a", desc = "Append mode" },
  { lhs = "o", mode = "n", rhs = "o", desc = "Open line below" },
  { lhs = "O", mode = "n", rhs = "O", desc = "Open line above" },
  { lhs = "I", mode = "n", rhs = "I", desc = "Insert at line start" },
  { lhs = "A", mode = "n", rhs = "A", desc = "Insert at line end" },
  { lhs = "<Esc>", mode = "i", rhs = "<Esc>", desc = "Exit insert mode" },
  { lhs = "<C-[>", mode = "i", rhs = "<C-[>", desc = "Exit insert mode" },
  { lhs = "<C-c>", mode = "i", rhs = "<C-c>", desc = "Exit insert mode" },
  { lhs = "v", mode = "n", rhs = "v", desc = "Visual mode" },
  { lhs = "V", mode = "n", rhs = "V", desc = "Visual line mode" },
  { lhs = "<C-v>", mode = "n", rhs = "<C-v>", desc = "Visual block mode" },
  { lhs = "<Esc>", mode = "v", rhs = "<Esc>", desc = "Exit visual mode" },
  -- Cursor movement
  { lhs = "h", mode = "n", rhs = "h", desc = "Move left" },
  { lhs = "j", mode = "n", rhs = "j", desc = "Move down" },
  { lhs = "k", mode = "n", rhs = "k", desc = "Move up" },
  { lhs = "l", mode = "n", rhs = "l", desc = "Move right" },
  { lhs = "w", mode = "n", rhs = "w", desc = "Word forward" },
  { lhs = "b", mode = "n", rhs = "b", desc = "Word backward" },
  { lhs = "e", mode = "n", rhs = "e", desc = "End of word" },
  { lhs = "0", mode = "n", rhs = "0", desc = "Start of line" },
  { lhs = "^", mode = "n", rhs = "^", desc = "First non-blank" },
  { lhs = "$", mode = "n", rhs = "$", desc = "End of line" },
  { lhs = "gg", mode = "n", rhs = "gg", desc = "Go to first line" },
  { lhs = "G", mode = "n", rhs = "G", desc = "Go to last line" },
  { lhs = "%", mode = "n", rhs = "%", desc = "Matching bracket" },
  -- Editing
  { lhs = "x", mode = "n", rhs = "x", desc = "Delete character" },
  { lhs = "X", mode = "n", rhs = "X", desc = "Delete character before" },
  { lhs = "r", mode = "n", rhs = "r", desc = "Replace character" },
  { lhs = "R", mode = "n", rhs = "R", desc = "Replace mode" },
  { lhs = "d", mode = "n", rhs = "d", desc = "Delete operator" },
  { lhs = "dd", mode = "n", rhs = "dd", desc = "Delete line" },
  { lhs = "D", mode = "n", rhs = "D", desc = "Delete to end of line" },
  { lhs = "c", mode = "n", rhs = "c", desc = "Change operator" },
  { lhs = "cc", mode = "n", rhs = "cc", desc = "Change line" },
  { lhs = "C", mode = "n", rhs = "C", desc = "Change to end of line" },
  { lhs = "s", mode = "n", rhs = "s", desc = "Substitute character" },
  { lhs = "S", mode = "n", rhs = "S", desc = "Substitute line" },
  { lhs = "y", mode = "n", rhs = "y", desc = "Yank operator" },
  { lhs = "yy", mode = "n", rhs = "yy", desc = "Yank line" },
  { lhs = "Y", mode = "n", rhs = "Y", desc = "Yank to end of line" },
  { lhs = "p", mode = "n", rhs = "p", desc = "Paste after" },
  { lhs = "P", mode = "n", rhs = "P", desc = "Paste before" },
  { lhs = ">", mode = "n", rhs = ">", desc = "Indent" },
  { lhs = "<", mode = "n", rhs = "<", desc = "Unindent" },
  { lhs = ">>", mode = "n", rhs = ">>", desc = "Indent line" },
  { lhs = "<<", mode = "n", rhs = "<<", desc = "Unindent line" },
  -- Undo/redo
  { lhs = "u", mode = "n", rhs = "u", desc = "Undo" },
  { lhs = "<C-r>", mode = "n", rhs = "<C-r>", desc = "Redo" },
  -- Search
  { lhs = "/", mode = "n", rhs = "/", desc = "Search forward" },
  { lhs = "?", mode = "n", rhs = "?", desc = "Search backward" },
  { lhs = "n", mode = "n", rhs = "n", desc = "Next match" },
  { lhs = "N", mode = "n", rhs = "N", desc = "Previous match" },
  { lhs = "*", mode = "n", rhs = "*", desc = "Search word forward" },
  { lhs = "#", mode = "n", rhs = "#", desc = "Search word backward" },
  -- Insert mode editing
  { lhs = "<BS>", mode = "i", rhs = "<BS>", desc = "Backspace" },
  { lhs = "<C-h>", mode = "i", rhs = "<C-h>", desc = "Delete character before" },
  { lhs = "<C-w>", mode = "i", rhs = "<C-w>", desc = "Delete word before" },
  { lhs = "<C-u>", mode = "i", rhs = "<C-u>", desc = "Delete to start of line" },
  { lhs = "<Del>", mode = "i", rhs = "<Del>", desc = "Delete character" },
  -- Visual mode
  { lhs = "h", mode = "v", rhs = "h", desc = "Move left" },
  { lhs = "j", mode = "v", rhs = "j", desc = "Move down" },
  { lhs = "k", mode = "v", rhs = "k", desc = "Move up" },
  { lhs = "l", mode = "v", rhs = "l", desc = "Move right" },
  { lhs = "d", mode = "v", rhs = "d", desc = "Delete selection" },
  { lhs = "x", mode = "v", rhs = "x", desc = "Delete selection" },
  { lhs = "y", mode = "v", rhs = "y", desc = "Yank selection" },
  { lhs = "c", mode = "v", rhs = "c", desc = "Change selection" },
  { lhs = "r", mode = "v", rhs = "r", desc = "Replace in selection" },
  { lhs = "s", mode = "v", rhs = "s", desc = "Substitute selection" },
  { lhs = ">", mode = "v", rhs = ">", desc = "Indent selection" },
  { lhs = "<", mode = "v", rhs = "<", desc = "Unindent selection" },
}

--- Creates explicit keymaps for default Neovim behaviors
-- These keymaps replicate the default Neovim behavior but are now instrumentable
local function create_default_keymaps(opts)
  local created_keymaps = {}
  local user_defaults = opts.default_neovim_keymaps or {}

  -- If user specified a list, filter to only those
  local mappings_to_create = default_neovim_mappings
  if #user_defaults > 0 then
    mappings_to_create = {}
    local user_map = {}
    for _, v in ipairs(user_defaults) do
      user_map[v.lhs .. "::" .. v.mode] = true
    end
    for _, mapping in ipairs(default_neovim_mappings) do
      if user_map[mapping.lhs .. "::" .. mapping.mode] then
        table.insert(mappings_to_create, mapping)
      end
    end
  end

  for _, mapping in ipairs(mappings_to_create) do
    local key = mapping.mode .. "__" .. mapping.lhs .. "__" .. "-1"

    -- Check if this keymap already exists (user or other plugin defined it)
    local existing = vim.fn.maparg(mapping.lhs, mapping.mode)
    if existing == "" then
      -- Create the keymap with the default behavior
      vim.keymap.set(mapping.mode, mapping.lhs, mapping.rhs, {
        desc = mapping.desc,
        noremap = true,
        silent = true,
      })

      -- Get the newly created keymap info
      local new_keymaps = vim.api.nvim_get_keymap(mapping.mode)
      for _, km in ipairs(new_keymaps) do
        if km.lhs == mapping.lhs then
          table.insert(created_keymaps, km)
          log.info("Created default keymap: " .. km.lhs .. " in mode " .. km.mode)
          break
        end
      end
    else
      log.debug("Keymap already exists, not creating default: " .. mapping.lhs)
    end
  end

  return created_keymaps
end

local function instrument_keymap(keymap, opts)
  log.info(
    string.format("Existing keymap lhs:%s: mode:%s: desc:%s: rhs:%s:", keymap.lhs, keymap.mode, keymap.desc, keymap.rhs)
  )

  local function amend_keymap(km)
    local keymap_fn = vim.keymap
    keymap_fn.amend = require("keymap-amend")

    if opts.notify and opts.very_verbose then
      vim.notify(km.lhs .. " is amended!", vim.log.levels.INFO)
    end
    keymap_fn.amend(km.mode, km.lhs, function(original)
      if opts.notify and opts.very_verbose then
        log.info("Original: " .. vim.inspect(original))
        vim.notify(km.lhs .. " is executed!", vim.log.levels.INFO)
      end
      -- Capture the command multiplier (count) before executing the original
      -- vim.v.count is 0 when no count is provided, vim.v.count1 is always at least 1
      local cnt = vim.v.count
      if cnt == 0 then
        cnt = 1
      end
      -- For count == 1, just call original() which handles mode transitions correctly
      -- For count > 1, use vim.cmd.normal which properly applies counts without breaking mode changes
      if cnt > 1 and km.rhs and type(km.rhs) == "string" then
        vim.cmd.normal({ cnt .. km.lhs, bang = true })
      else
        original()
      end
      count_keymap(km.lhs, km.mode, "keymap", opts.notify and opts.debug, km.noremap, cnt)
    end, { desc = km.desc })
  end
  local function try_reset(km)
    amend_keymap(km)
    -- reset_keymap(km)
  end
  if not opts.dryrun then
    local status = xpcall(try_reset, log.error, keymap)
    if not status then
      log.warn("Keymap reset failed", keymap)
    end
  else
    log.info("Dryrun: " .. keymap.lhs)
  end
  -- log.debug("Keymap", keymap)
end

local options = {
  dryrun = false,
  notify = false,
  very_verbose = false,
  included_lhs = {},
  excluded_rhs = {},
  include_rhs = false,
  default_neovim_keymaps = {},
}
local function instrument(_count, _count_keymap, notify, opts)
  local o = vim.tbl_deep_extend(
    "force",
    options,
    { dryrun = false, notify = notify, modes = { "n", "v", "i" }, plugs = false },
    opts or {}
  )

  log.info(o)

  -- Create explicit keymaps for default Neovim behaviors if requested
  if o.default_neovim_keymaps and #o.default_neovim_keymaps >= 0 then
    log.info("Creating default Neovim keymaps for instrumentation")
    create_default_keymaps(o)
  end

  local maps = {} ---@type vim.api.keyset.get_keymap[]
  for _, mode in ipairs(o.modes) do
    vim.list_extend(maps, vim.api.nvim_get_keymap(mode))
    vim.list_extend(maps, vim.api.nvim_buf_get_keymap(0, mode))
  end
  local items = {} ---@type vim.api.keyset.get_keymap[]
  local done = {} ---@type table<string, boolean>
  for _, km in ipairs(maps) do
    local key = km.mode .. "__" .. km.lhs .. "__" .. km.buffer
    local keep = true
    if o.plugs == false and km.lhs:match("^<Plug>") then
      keep = false
    end
    if keep and not done[key] then
      done[key] = true
      items[#items + 1] = km
    end
  end

  local keymaps = items

  log.debug("Original Keymaps", vim.inspect(keymaps))

  local included_lhs = {}
  for _, v in ipairs(o.included_lhs) do
    included_lhs[v] = true
  end

  log.debug("Instrumenting " .. vim.inspect(o))
  log.info("Leader:" .. vim.g.mapleader .. ":")
  log.info("LocalLeader:" .. vim.g.maplocalleader .. ":")
  for _, keymap in ipairs(keymaps) do
    local lhs = keymap.lhs
    local include = next(o.included_lhs) == nil or included_lhs[lhs]
    if lhs then
      local is_number = lhs:match("^%d+")
      if is_number then
        log.info("Skipping number " .. lhs)
      else
        if include then
          instrument_keymap(keymap, o)
          table.insert(M.stats.included_lhs, { lhs = lhs, mode = keymap.mode, buffer = keymap.buffer })
        else
          log.info("Skipping " .. lhs)
          table.insert(M.stats.skipped_lhs, { lhs = lhs, mode = keymap.mode, buffer = keymap.buffer })
        end
      end
    end
  end

  local mode_counts = {}
  for _, km in ipairs(M.stats.included_lhs) do
    local mode = km.mode or "n"
    mode_counts[mode] = (mode_counts[mode] or 0) + 1
  end
  stats.mode_counts = mode_counts

  -- local instrumented_keymaps = vim.api.nvim_get_keymap "n"
  -- log.debug("Instrumented Keymaps", instrumented_keymaps)
  -- log.debug("Instrumentation stats: " .. string.format("%s", vim.inspect(stats)))
  log.info("Instrumentation summary: " .. "mode_counts: " .. vim.inspect(mode_counts))

  state.instrumented = true

  return stats
end

M.setup = instrument
M.state = state
M.stats = stats

return M
