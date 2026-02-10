# Code Coverage Support for Testing Infrastructure

**Date:** 2026-02-10
**Session:** Current session
**Agent:** build

## Feature Request

The user requested adding code coverage support to the keymap-stats.nvim plugin's test infrastructure to better understand test coverage and improve code quality.

## Implementation Summary

### Solution

Integrated LuaCov for code coverage tracking in the test suite:

1. **Added `.luacov` configuration file**
   - Configured HTML reporter for human-readable coverage reports
   - Set minimum coverage threshold to 80%
   - Included only `lua/` directory (plugin source code)
   - Excluded `tests/`, `.tests/`, and `lua/lazy/` directories
   - Enabled colorized terminal output and missing line reporting

2. **Modified `tests/busted.lua`**
   - Added COVERAGE environment variable detection
   - Integrated luacov runner when `COVERAGE=1` is set
   - Added graceful fallback if luacov is not installed
   - Maintained backward compatibility (tests run normally without coverage)

3. **Added Makefile targets**
   - `make test-coverage`: Runs tests with coverage enabled and generates HTML report
   - `make view-coverage`: Opens the generated HTML report in default browser
   - Added helpful error messages for missing luacov installation

4. **Updated `.gitignore`**
   - Added `luacov.report.html` to prevent committing generated reports

5. **Enhanced test coverage in `tests/core/init_spec.lua`**
   - Added comprehensive API module tests (initialization, counting, termcode handling)
   - Added init module tests (default options, custom setup, state management)
   - Added state management tests (plugin tracking structures)

## Usage

Run tests with coverage:

```bash
make test-coverage
```

View the coverage report:

```bash
make view-coverage
```

Or manually:

```bash
COVERAGE=1 nvim -l ./tests/busted.lua tests
luacov
# Open luacov.report.html in browser
```

## Dependencies

- **luacov**: Install via `luarocks install luacov`
- Coverage is optional - tests run normally without it

## Technical Details

- Uses busted's built-in luacov integration pattern
- Coverage tracking starts before loading any plugin code
- HTML report shows line-by-line coverage with color coding
- Missing lines are shown in the terminal output

## Future Considerations

- Could integrate coverage reporting into CI/CD pipeline
- Could add coverage badges to README
- Consider adding coverage thresholds as build requirements
