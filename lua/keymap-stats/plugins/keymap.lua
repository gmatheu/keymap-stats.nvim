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

local function instrument_keymap(keymap, opts)
  log.info(
    string.format("Existing keymap lhs:%s, mode:%s, desc:%s, rhs:%s", keymap.lhs, keymap.mode, keymap.desc, keymap.rhs)
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
      original()
      count_keymap(km.lhs, km.mode, "keymap", opts.notify, km.noremap)
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
}
local function instrument(_count, _count_keymap, notify, opts)
  local o = vim.tbl_deep_extend("force", options, { dryrun = false, notify = notify }, opts or {})
  -- vim.notify("Instrumented", vim.log.levels.INFO, { title = plugin_name })
  local keymaps = vim.api.nvim_get_keymap("n")
  log.debug("Original Keymaps", vim.inspect(keymaps))

  local included_lhs = {}
  for _, v in ipairs(o.included_lhs) do
    included_lhs[v] = true
  end
  log.info("Instrumenting " .. vim.inspect(o))
  for _, keymap in ipairs(keymaps) do
    local lhs = keymap.lhs
    local include = next(o.included_lhs) == nil or included_lhs[lhs]
    local is_number = lhs:match("^%d+")
    if is_number then
      log.info("Skipping number " .. lhs)
    else
      if include then
        instrument_keymap(keymap, o)
        table.insert(M.stats.included_lhs, { lhs = lhs })
      else
        log.info("Skipping " .. lhs)
        table.insert(M.stats.skipped_lhs, { lhs = lhs })
      end
    end
  end

  -- local instrumented_keymaps = vim.api.nvim_get_keymap "n"
  -- log.debug("Instrumented Keymaps", instrumented_keymaps)
  log.debug("Instrumentation stats: " .. string.format("%s", vim.inspect(stats)))

  state.instrumented = true
end

M.setup = instrument
M.state = state
M.stats = stats

return M
