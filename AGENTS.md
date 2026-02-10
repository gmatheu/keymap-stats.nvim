# Agent Guidelines for keymap-stats.nvim

> **Repository:** Neovim plugin for tracking keymap usage statistics
> **Language:** Lua (Neovim plugin)
> **Test Framework:** busted (via lazy.nvim minit)

## Build, Test, and Lint Commands

```bash
# Run all tests
make test

# Run a single test file
nvim -l ./tests/busted.lua tests/core/init_spec.lua
nvim -l ./tests/busted.lua tests/keymap-stats_spec.lua

# Debug test environment
make test-debug

# Lint with selene
make lint

# Format with StyLua
stylua lua/ tests/

# View plugin logs
make tail-log
make truncate-log
```

## Code Style Guidelines

### Formatting (StyLua)
- **Indentation:** 2 spaces (not tabs)
- **Line width:** 120 columns max
- **Sort requires:** Enabled (alphabetical order)

### Lua Patterns
```lua
-- Module pattern
local M = {}

-- Private functions (local only)
local function helper_fn() end

-- Public API
function M.public_fn() end

return M
```

### Type Annotations (EmmyLua)
```lua
-- @class for types
-- @type for variable types
-- Use vim.tbl_deep_extend for config merging
```

### Naming Conventions
- **Modules:** `M` for the main table
- **State tables:** `state` (for runtime state)
- **Stats tables:** `stats` (for collected statistics)
- **Options:** `opts` or `options`
- **Private fields:** prefix with `_` or keep as local variables
- **Functions:** `snake_case`
- **Constants:** `SCREAMING_SNAKE_CASE` or `local defaults = {}`

### Error Handling
```lua
-- Use xpcall with error logging
local result = xpcall(fn, log_error, arg1, arg2)
if not result then
  log.error("Operation failed")
end

-- Protected calls for optional dependencies
```

### Logging
```lua
local log = require("keymap-stats.log")

-- Available levels: trace, debug, info, warn, error, fatal
log.debug("Debug message", data)
log.info("Info message")
log.warn("Warning", details)
log.error("Error occurred", error_obj)
```

## Project Structure

```
lua/keymap-stats/
├── init.lua          -- Main entry point, setup()
├── api.lua           -- Core counting API
├── log.lua           -- Logging utility
├── command.lua       -- User commands (:KeymapStats)
├── report.lua        -- Report generation
└── plugins/
    ├── keymap.lua    -- Keymap instrumentation
    ├── which-key.lua -- Which-key integration
    └── hardtime.lua  -- Hardtime integration

tests/
├── busted.lua        -- Test bootstrap (lazy.nvim)
├── minimal.lua       -- Minimal test config
├── core/init_spec.lua-- Environment tests
└── keymap-stats_spec.lua -- Plugin tests
```

## Test Conventions

```lua
-- Busted style with describe/it blocks
describe("module name", function()
  it("should do something", function()
    -- Assertions
    assert.is_true(value)
    assert.is_not_nil(obj)
    assert.same({a=1}, {a=1})  -- deep equality
  end)
end)
```

## Key Dependencies

- **lazy.nvim:** Plugin manager (used in tests)
- **busted:** Test framework
- **selene:** Lua linter
- **StyLua:** Lua formatter
- **luacheck:** Additional linting

## Configuration Pattern

```lua
-- Default config with environment variable overrides
local defaults = {
  debug = false or get_env_var("debug"),
  notify = false or get_env_var("notify"),
  plugins = { which_key = true, hardtime = true, keymap = true },
}

-- Merge user options
M.options = vim.tbl_deep_extend("force", {}, defaults, opts or {})
```

## Pre-commit Hooks

The project uses pre-commit with:
- StyLua formatting
- Luacheck linting
- Trailing whitespace removal
- YAML validation

## Important Notes

- Plugin uses `keymap-amend.nvim` for keymap instrumentation
- State is maintained in module-level tables
- Tests run in isolated `.tests/` directory
- Log files stored in `stdpath("data")`
