local M = {}

local api = require("keymap-stats.api")
local log = require("keymap-stats.log")

local instrumented = false
local stats = {
  callback_count = 0,
  rhs_count = 0,
  excluded_rhs_lhs = {},
  included_lhs = {},
  skipped_lhs = {},
  plugins = {},
}

M.logfile = log.file
M.stats = stats

local state = {
  excluded_rhs = {},
  plugins = {},
}

local plugin_name = api.state.plugin_name

-- @class Options
local function get_env_var(name)
  local env_name = plugin_name:upper():gsub("-", "_"):gsub(".", "_") .. "_" .. name:upper()
  return os.getenv(env_name)
end

local defaults = {
  name = plugin_name,
  autoinstrument = true,
  plugins = { which_key = true, hardtime = true, keymap = true },
  debug = false or get_env_var("debug"),
  notify = false or get_env_var("notify"),
  very_verbose = false or get_env_var("very_verbose"),
  included_lhs = {},
  excluded_rhs = {},
  include_rhs = false,
  default_neovim_keymaps = {},
}
--
-- @type Options
M.options = {}

local function config(opts)
  M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
  log.new({ plugin = M.options.name })

  for _, v in ipairs(M.options.excluded_rhs) do
    log.debug(v)
    -- table.insert(config.excluded_rhs, v.lhs)
    state.excluded_rhs[v.lhs] = true
  end
end
-- end:options.lua }}}

function M.setup(opts)
  config(opts)

  log.debug("Config: " .. vim.inspect(opts))
  local function try_instrument(enabled, mod, module)
    if enabled then
      local log_error = function(e)
        log.error("Instrument error: " .. e)
      end
      local fn = mod.setup
      local result = xpcall(fn, log_error, api.count, api.count_keymap, M.options.debug, M.options)
      if result then
        log.debug("Instrumented: " .. module)
        stats.plugins[module] = mod.stats
        state.plugins[module] = mod.state
      else
        log.debug("Failed to instrument: " .. module)
      end
    end
  end
  if not instrumented and M.options.autoinstrument then
    try_instrument(M.options.plugins.which_key, require("keymap-stats.plugins.which-key"), "which-key")
    try_instrument(M.options.plugins.keymap, require("keymap-stats.plugins.keymap"), "keymap")
    try_instrument(M.options.plugins.hardtime, require("keymap-stats.plugins.hardtime"), "hardtime")
    instrumented = true
    if opts.notify then
      vim.notify("hardtime instrumentation completed", vim.log.levels.INFO, { title = plugin_name })
      if opts.debug then
        vim.notify("State: " .. vim.inspect(state), vim.log.levels.DEBUG, { title = plugin_name })
      end
    end
  end
  require("keymap-stats.command").setup()
end

M.state = state

return M
