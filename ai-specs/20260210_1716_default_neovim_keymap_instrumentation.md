# Default Neovim Keymap Instrumentation Feature

**Date:** 2026-02-10
**Session:** ses_3b773f088ffeh91CJ9k3D0wUcV
**Agent:** sisyphus, build

## Feature Request

The user requested instrumentation of default Neovim keymaps (built-in behaviors that don't appear in `vim.api.nvim_get_keymap()`). Examples include:

- `<C-e>` and `<C-d>` (scrolling)
- `<Esc>` and `i` (mode switching)
- Built-in editing commands like `dd`, `yy`, `p`

## Implementation Summary

### Problem

Default Neovim keymaps like `<C-e>`, `<C-d>`, `i`, `<Esc>` are built into Neovim's core and don't appear in the API's keymap list. To instrument them, explicit keymaps must be created first.

### Solution

Created a system to define and register default Neovim keymaps before instrumentation:

1. **Added `default_neovim_keymaps` configuration option**
   - In `lua/keymap-stats/plugins/keymap.lua` and `lua/keymap-stats/init.lua`
   - Allows users to enable/disable default keymap instrumentation
   - Can specify which specific keymaps to instrument

2. **Defined 80+ default keymap mappings**
   - **Scrolling:** `<C-e>`, `<C-y>`, `<C-d>`, `<C-u>`, `<C-f>`, `<C-b>`
   - **Mode switching:** `i`, `a`, `o`, `O`, `I`, `A`, `<Esc>`, `v`, `V`, `<C-v>`
   - **Cursor movement:** `h`, `j`, `k`, `l`, `w`, `b`, `e`, `0`, `^`, `$`, `gg`, `G`, `%`
   - **Editing:** `x`, `X`, `r`, `R`, `d`, `dd`, `D`, `c`, `cc`, `C`, `s`, `S`, `y`, `yy`, `Y`, `p`, `P`, `>`, `<`
   - **Undo/redo:** `u`, `<C-r>`
   - **Search:** `/`, `?`, `n`, `N`, `*`, `#`
   - **Insert mode:** `<BS>`, `<C-h>`, `<C-w>`, `<C-u>`, `<Del>`
   - **Visual mode:** All movement and editing operators

3. **Implementation approach**
   - Created explicit keymaps that replicate default Neovim behavior using `vim.keymap.set()`
   - These keymaps are then picked up by the existing instrumentation flow
   - Only creates keymaps that don't already exist (preserves user customizations)
   - Uses the `keymap-amend.nvim` library for instrumentation

## Usage Examples

Enable all default keymaps:

```lua
require("keymap-stats").setup({
  default_neovim_keymaps = {}  -- Empty table enables all defaults
})
```

Enable only specific keymaps:

```lua
require("keymap-stats").setup({
  default_neovim_keymaps = {
    { lhs = "<C-e>", mode = "n" },
    { lhs = "<C-d>", mode = "n" },
    { lhs = "i", mode = "n" },
    { lhs = "<Esc>", mode = "i" },
  }
})
```

Disable default keymap instrumentation (default behavior):

```lua
require("keymap-stats").setup({
  default_neovim_keymaps = nil  -- or omit the option entirely
})
```

## Technical Details

- Keymaps are stored in a structured table with `lhs`, `mode`, `rhs`, and optional `desc`
- The `rhs` field contains Lua functions that replicate default Neovim behavior
- For example, scrolling uses `vim.api.nvim_feedkeys()` with appropriate key sequences
- Mode switching uses `vim.api.nvim_command('stopinsert')` for `<Esc>` and `vim.api.nvim_feedkeys()` for entering insert/visual modes

## Future Considerations

- The list of 80+ mappings covers the most commonly used defaults but could be extended
- Some complex behaviors (like `dd` with counts) are simplified in the current implementation
- Visual block mode (`<C-v>`) behaviors could be further refined
