# Fix: Handle Function-Based Keymaps in keymap-stats.nvim

**Date:** 2026-02-10  
**Issue:** E5108: Error executing lua - Invalid 'str': Expected Lua string  
**File:** `lua/keymap-stats/plugins/keymap.lua`

## Problem Description

When using keymap-stats.nvim with the Leap.nvim plugin, pressing Leap keymaps (like `s`, `S`, or `gs`) caused the following error:

```
E5108: Error executing lua: ...keymap-amend.lua:85: Invalid 'str': Expected Lua string
stack traceback:
    [C]: in function 'termcodes'
    ...keymap-amend.lua:85: in function 'original'
    ...keymap-stats/plugins/keymap.lua:192: in function 'rhs'
```

## Root Cause

Leap.nvim registers keymaps with **function-based RHS** (right-hand side) values:

```lua
vim.keymap.set({"n", "x", "o"}, "s", function()
  leap.leap({ target_windows = { vim.api.nvim_get_current_win() } })
end, { desc = "Leap forward to" })
```

However, `keymap-amend.nvim` (which keymap-stats uses for instrumentation) expects keymaps to have **string-based RHS** values. When `keymap-amend` tries to wrap a function-based keymap, its internal `original()` function attempts to call:

```lua
vim.api.nvim_replace_termcodes(rhs, true, true, true)
```

This fails because `termcodes()` only accepts strings, not functions.

## Solution

Added a type check at the beginning of `instrument_keymap()` to detect function-based keymaps and skip instrumentation for them:

```lua
-- Skip keymaps with function-based RHS as keymap-amend doesn't handle them properly
-- It tries to call vim.api.nvim_replace_termcodes() on the function, which fails
if keymap.rhs and type(keymap.rhs) == "function" then
  log.info(string.format("Skipping function-based keymap: %s in mode %s", keymap.lhs, keymap.mode))
  return
end
```

## Implementation Details

**Location:** `lua/keymap-stats/plugins/keymap.lua`, lines 166-171

The fix adds an early return before attempting to call `keymap-amend`, preventing the crash. Function-based keymaps are logged as skipped so users can track which keymaps aren't being instrumented.

## Trade-offs

- **Function-based keymaps won't be counted** in usage statistics since they can't be instrumented by keymap-amend
- **String-based keymaps continue to work normally** with full instrumentation
- This is a limitation of the underlying `keymap-amend` library, not keymap-stats itself

## Future Considerations

To instrument function-based keymaps in the future, we would need to either:
1. Patch `keymap-amend` to handle function-based keymaps
2. Implement a different instrumentation approach that doesn't rely on keymap-amend for function-based mappings
3. Use Neovim's native keymap API to wrap function-based keymaps directly

## References

- Leap.nvim: https://codeberg.org/andyg/leap.nvim
- keymap-amend.nvim: https://github.com/gmatheu/keymap-amend.nvim
- Neovim keymap API: `:help vim.keymap.set()`
