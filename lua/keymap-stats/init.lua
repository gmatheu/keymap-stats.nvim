local M = {}

local log = require("keymap-stats.log")

local instrumented = false
local stats = {
  callback_count = 0,
  rhs_count = 0,
  excluded_rhs_lhs = {},
}

local state = {
  excluded_rhs = {},
}

-- start:options.lua {{{1
local excluded_rhs = {
  { lhs = "<Esc>", rhs = "<Cmd> noh <CR>" },
  { lhs = "<Esc><Esc>", rhs = "<Cmd> nohlsearch<CR>" },
  { lhs = "&", rhs = ":&&<CR>" },
  { lhs = ",lv", rhs = "<Cmd>VenvSelect<CR>" },
  { lhs = ",gst", rhs = "<Cmd>Git<CR>" },
  { lhs = ",uz", rhs = "<Cmd>ColorizerToggle<CR>" },
  { lhs = ",tv", rhs = "<Cmd>ToggleTerm size=80 direction=vertical<CR>" },
  { lhs = ",tl", rhs = "<Cmd>Git<CR>" },
  { lhs = ",x", rhs = "<Cmd>bd<CR>" },
  { lhs = ",tt", rhs = "<Cmd>TroubleToggle document_diagnostics<CR>" },
  { lhs = ",zl", rhs = "<Cmd>ZkLinks<CR>" },
  { lhs = ",qr", rhs = "<Cmd>OverseerRun<CR>" },
  { lhs = ",zt", rhs = "<Cmd>ZkTags<CR>" },
  { lhs = ",,", rhs = "<Cmd> :e#<CR>" },
  { lhs = ",qt", rhs = "<Cmd>OverseerToggle<CR>" },
  { lhs = ",zn", rhs = "<Cmd>ZkNew<CR>" },
  { lhs = ",Sl", rhs = "<Cmd>Autosession search<CR>" },
  { lhs = ",th", rhs = "<Cmd>ToggleTerm size=10 direction=horizontal<CR>" },
  { lhs = ",Sr", rhs = "<Cmd>SessionRestore<CR>" },
  { lhs = ",fT", rhs = "<Cmd>TodoTelescope<CR>" },
  { lhs = ",Ss", rhs = "<Cmd>SessionSave<CR>" },
  { lhs = ",ss", rhs = "<Cmd>MurenToggle<CR>" },
  { lhs = ",qa", rhs = "<Cmd>OverseerQuickAction<CR>" },
  { lhs = ",tw", rhs = "<Cmd>TroubleToggle workspace_diagnostics<CR>" },
  { lhs = ",td", rhs = "<Cmd>TroubleToggle document_diagnostics<CR>" },
  { lhs = ",gg", rhs = "<Cmd>Git<CR>" },
  { lhs = ",<CR>", rhs = "<Cmd> w <CR>" },
  { lhs = ",e", rhs = "<Cmd>Neotree toggle<CR>" },
  { lhs = ",Sd", rhs = "<Cmd>Autosession delete<CR>" },
  { lhs = ",tf", rhs = "<Cmd>ToggleTerm direction=float<CR>" },
  { lhs = ",Q", rhs = "<Cmd>confirm qall<CR>" },
  { lhs = ",ra", rhs = '<Cmd>lua require("renamer").rename()<CR>' },
  { lhs = ";", rhs = ":" },
  { lhs = "U", rhs = "<C-R>" },
  { lhs = "Y", rhs = "y$" },
  { lhs = "[%", rhs = "<Plug>(MatchitNormalMultiBackward)" },
  { lhs = "\\", rhs = "<Cmd>FocusSplitRight<CR>" },
  { lhs = "]%", rhs = "<Plug>(MatchitNormalMultiForward)" },
  { lhs = "g%", rhs = "<Plug>(MatchitNormalBackward)" },
  { lhs = "gal", rhs = "<Cmd>lua require('textcase').quick_replace('to_lower_case')<CR>" },
  { lhs = "gaL", rhs = "<Cmd>lua require('textcase').lsp_rename('to_lower_case')<CR>" },
  { lhs = "gaol", rhs = "<Cmd>lua require('textcase').operator('to_lower_case')<CR>" },
  { lhs = "gau", rhs = "<Cmd>lua require('textcase').quick_replace('to_upper_case')<CR>" },
  { lhs = "gaU", rhs = "<Cmd>lua require('textcase').lsp_rename('to_upper_case')<CR>" },
  { lhs = "gaou", rhs = "<Cmd>lua require('textcase').operator('to_upper_case')<CR>" },
  { lhs = "gap", rhs = "<Cmd>lua require('textcase').quick_replace('to_pascal_case')<CR>" },
  { lhs = "gaP", rhs = "<Cmd>lua require('textcase').lsp_rename('to_pascal_case')<CR>" },
  { lhs = "gaop", rhs = "<Cmd>lua require('textcase').operator('to_pascal_case')<CR>" },
  { lhs = "gad", rhs = "<Cmd>lua require('textcase').quick_replace('to_dash_case')<CR>" },
  { lhs = "gaD", rhs = "<Cmd>lua require('textcase').lsp_rename('to_dash_case')<CR>" },
  { lhs = "gaod", rhs = "<Cmd>lua require('textcase').operator('to_dash_case')<CR>" },
  { lhs = "gas", rhs = "<Cmd>lua require('textcase').quick_replace('to_snake_case')<CR>" },
  { lhs = "gaS", rhs = "<Cmd>lua require('textcase').lsp_rename('to_snake_case')<CR>" },
  { lhs = "gaos", rhs = "<Cmd>lua require('textcase').operator('to_snake_case')<CR>" },
  { lhs = "gac", rhs = "<Cmd>lua require('textcase').quick_replace('to_camel_case')<CR>" },
  { lhs = "gaC", rhs = "<Cmd>lua require('textcase').lsp_rename('to_camel_case')<CR>" },
  { lhs = "gaoc", rhs = "<Cmd>lua require('textcase').operator('to_camel_case')<CR>" },
  { lhs = "gan", rhs = "<Cmd>lua require('textcase').quick_replace('to_constant_case')<CR>" },
  { lhs = "gaN", rhs = "<Cmd>lua require('textcase').lsp_rename('to_constant_case')<CR>" },
  { lhs = "gaon", rhs = "<Cmd>lua require('textcase').operator('to_constant_case')<CR>" },
  { lhs = "ga.", rhs = "<Cmd>TextCaseOpenTelescope<CR>" },
  { lhs = "j", rhs = "v:count == 0 ? 'gj' : 'j'" },
  { lhs = "k", rhs = "v:count == 0 ? 'gk' : 'k'" },
  { lhs = "|", rhs = "<Cmd>FocusSplitDown<CR>" },
  { lhs = "<Plug>(MatchitNormalMultiForward)", rhs = ':<C-U>call matchit#MultiMatch("W",  "n")<CR>' },
  { lhs = "<Plug>(MatchitNormalMultiBackward)", rhs = ':<C-U>call matchit#MultiMatch("bW", "n")<CR>' },
  { lhs = "<Plug>(MatchitNormalBackward)", rhs = ":<C-U>call matchit#Match_wrapper('',0,'n')<CR>" },
  { lhs = "<Plug>(MatchitNormalForward)", rhs = ":<C-U>call matchit#Match_wrapper('',1,'n')<CR>" },
  {
    lhs = "<Plug>PlenaryTestFile",
    rhs = ":lua require('plenary.test_harness').test_file(vim.fn.expand(\"%:p\"))<CR>",
  },
  { lhs = "<C-S>", rhs = "<Cmd> w <CR>" },
  { lhs = "<C-'>", rhs = '<Cmd>execute v:count . "ToggleTerm"<CR>' },
  { lhs = "<F4>", rhs = "<Cmd> UndotreeToggle <CR>" },
  { lhs = "<C-C>", rhs = "<Cmd> %y+ <CR>" },
  { lhs = "<C-J>", rhs = "<Cmd>MoveLine 1<CR>" },
  { lhs = "<C-Q>", rhs = "<Cmd>q!<CR>" },
  { lhs = "<F3>", rhs = "<Cmd>Neotree toggle<CR>" },
  { lhs = "<F7>", rhs = '<Cmd>execute v:count . "ToggleTerm"<CR>' },
  { lhs = "<C-W><C-D>", rhs = "<C-W>d" },
}
local plugin_name = "keymaps-analytics"
-- @class Options
local defaults = {
  name = plugin_name,
  plugins = { which_key = true, hardtime = true },
  debug = false or os.getenv(plugin_name:upper():gsub("-", "_") .. "_DEBUG"),
  notify = true,
  excluded_rhs = excluded_rhs,
}
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

---@diagnostic disable-next-line: unused-function
-- luacheck: ignore 211
local function should_include(rhs)
  return state.excluded_rhs[rhs] == nil
end

local function count(lhs, mode, action, notify, type)
  notify = notify or false
  action = action or "default"
  type = type or "keymap"

  lhs = vim.api.nvim_replace_termcodes(lhs, true, true, true)
  log.info(string.format("Executed lhs:%s mode:%s action:%s type:%s", lhs, mode, action, type))
  if notify then
    local message = string.format("%s executed [%s]: %s", type, action, lhs)
    vim.notify(message, vim.log.levels.INFO, { title = plugin_name })
  end
end
local function count_keymap(lhs, mode, action, notify)
  count(lhs, mode, action, notify, "keymap")
end

local function handler_meter(lhs, mode, callback)
  count_keymap(lhs, mode)
  callback()
end
local function handler_rhs_meter(lhs, mode, rhs)
  local function _wrap_rhs(expression)
    log.debug("Expression to be executed", expression)
    -- expression = "<Ignore>" .. expression
    expression = "" .. expression
    -- vim.notify(expression, vim.log.levels.INFO, { title = plugin_name })
    local replaced = vim.api.nvim_replace_termcodes(expression, true, true, true)
    log.debug("Replaced expression", replaced)
    -- vim.notify(string("Replaced: " .. replaced), vim.log.levels.INFO, { title = plugin_name })
    -- local success, result = pcall(vim.api.nvim_command, replaced)
    local success, result = pcall(vim.api.nvim_feedkeys, replaced, mode, false)
    -- local success, result = pcall(vim.api.nvim_input, replaced)
    if success then
      return result
    end
    log.error("Expression failed", replaced, "Result", result)
    vim.notify(
      string.format("Expression '%s' failed: %s", expression, result),
      vim.log.levels.ERROR,
      { title = plugin_name }
    )
    return expression
  end

  return handler_meter(lhs, mode, function()
    return _wrap_rhs(rhs)
  end)
end
local function rhs_to_cmd(rhs)
  local r = rhs
  log.error("Original rhs: " .. r)
  -- if r:lower():find "<cmd>" then r = rhs:gsub("<Cmd>", "") end
  -- -- r = r:gsub("<CR>", "")
  -- r = r:gsub("\r", "")
  --
  -- log.error("Santized rhs: " .. r)
  return r
end

local function instrument_keymap(keymap)
  log.info(string.format("Existing keymap lhs:%s, mode:%s, desc:%s", keymap.lhs, keymap.mode, keymap.desc))
  local function reset_keymap(km)
    if km.callback then
      local handler = function()
        handler_meter(km.lhs, km.mode, km.callback)
      end
      vim.keymap.set(km.mode, km.lhs, handler, {
        desc = km.desc,
        noremap = km.noremap,
        remap = km.remap,
        silent = km.silent,
        nowait = km.nowait,
      })
      stats.callback_count = stats.callback_count + 1
    else
      log.debug("Keymap rhs", km)
      -- if should_include(_keymap.lhs) then
      --   -- vim.notify(_keymap.lhs .. " >> " .. _keymap.rhs, vim.log.levels.INFO, { title = plugin_name })
      --   vim.keymap.set(_keymap.mode, _keymap.lhs, function()
      --     local cmd = rhs_to_cmd(_keymap.rhs)
      --     handler_rhs_meter(keymap.lhs, keymap.mode, cmd)
      --   end, {
      --     desc = _keymap.desc,
      --     noremap = true,
      --     silent = true,
      --     expr = true,
      --     nowait = true,
      --   })
      --   stats.rhs_count = stats.rhs_count + 1
      --   log.debug("Excluding: " .. _keymap.lhs)
      --   -- table.insert(stats.rhs_lhs, { lhs = _keymap.lhs, instrumented = true })
      -- else
      --   table.insert(stats.excluded_rhs_lhs, { lhs = _keymap.lhs, rhs = _keymap.rhs, instrumented = false })
      -- end
    end
  end
  local status = xpcall(reset_keymap, log.error, keymap)
  if not status then
    log.warn("Keymap reset failed", keymap)
  end
  -- log.debug("Keymap", keymap)
end

local function instrument(_count, _count_keymap, _notify)
  -- vim.notify("Instrumented", vim.log.levels.INFO, { title = plugin_name })
  local keymaps = vim.api.nvim_get_keymap("n")
  -- log.debug("Original Keymaps", keymaps)

  for _, keymap in ipairs(keymaps) do
    instrument_keymap(keymap)
  end

  -- local instrumented_keymaps = vim.api.nvim_get_keymap "n"
  -- log.debug("Instrumented Keymaps", instrumented_keymaps)
  log.debug("Instrumentation stats: " .. string.format("%s", vim.inspect(stats)))
  -- vim.notify(
  --   "Instrumentation stats: " .. string.format("%s", vim.inspect(stats)),
  --   vim.log.levels.DEBUG,
  --   { title = plugin_name }
  -- )

  instrumented = true
end

function M.setup(opts)
  config(opts)

  log.debug("Config: " .. vim.inspect(config))
  local function try_instrument(enabled, fn, module)
    if enabled then
      local log_error = function(e)
        log.error("Instrument error: " .. e)
      end
      local result = xpcall(fn, log_error, count, count_keymap, M.options.debug)
      if result then
        log.debug("Instrumented: " .. module)
      else
        log.debug("Failed to instrument: " .. module)
      end
    end
  end
  if not instrumented then
    -- try_instrument(M.options.plugins.which_key, require("x.plugins.which-key").setup, "which-key")
    -- try_instrument(M.options.plugins.hardtime, require("x.plugins.hardtime").setup, "hardtime")
    try_instrument(true, instrument, "default")
  end
  require("keymap-stats.command").setup()
end

return M
