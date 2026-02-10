# Command Multiplier Support for Keymap Instrumentation

## Request

User requested that the command multiplier (count) be taken into account when executing instrumented keymaps. For example, when executing `7j` to jump 7 lines down, the plugin should count it as 7 keymap executions instead of just 1.

## Implementation

### Changes Made

#### 1. `lua/keymap-stats/api.lua`

**Modified `count` function:**
- Added optional `cnt` parameter (defaults to 1)
- Now increments the keymap count by `cnt` instead of always by 1
- Updated log template to include the count value
- Updated notification message to display the multiplier (e.g., "keymap executed [action]: j (x7)")

**Modified `count_keymap` function:**
- Added `cnt` parameter to pass through to the `count` function

#### 2. `lua/keymap-stats/plugins/keymap.lua`

**Modified `amend_keymap` function:**
- Captures `vim.v.count` BEFORE executing the original keymap function
- This is critical because `vim.v.count` resets after command execution
- If count is 0 (no multiplier provided), defaults to 1
- Passes the captured count to `count_keymap`

### Key Technical Details

The implementation captures `vim.v.count` before calling `original()` because:
1. `vim.v.count` is 0 when no count is provided by the user
2. `vim.v.count1` is always at least 1 (defaults to 1 when no count provided)
3. After executing a command, `vim.v.count` may reset to 0
4. Therefore, we must capture it before executing the original keymap behavior

### Behavior Change

- **Before**: Pressing `7j` would count as 1 `j` execution
- **After**: Pressing `7j` correctly counts as 7 `j` executions

### Backwards Compatibility

- The `cnt` parameter is optional and defaults to 1
- All existing calls to `count` and `count_keymap` continue to work without modification
- The change only affects the instrumentation path in `keymap.lua`

## Files Modified

- `lua/keymap-stats/api.lua` - Added count parameter support
- `lua/keymap-stats/plugins/keymap.lua` - Captures and passes vim.v.count

## Testing

Tests pass successfully with `make test`. The implementation correctly handles:
- Commands without multipliers (defaults to count=1)
- Commands with multipliers (e.g., `5j`, `10k`, `3w`)
- Edge cases where count might be 0
