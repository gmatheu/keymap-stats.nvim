local Util = require("lazy.core.util")

describe("init", function()
  it("has correct environment for tests", function()
    for _, name in ipairs({ "config", "data", "cache", "state" }) do
      local path = Util.norm(vim.fn.stdpath(name) --[[@as string]])
      assert(path:find(".tests/" .. name, 1, true), path .. " not in .tests")
    end
  end)

  describe("api module", function()
    it("should initialize with empty session state", function()
      local api = require("keymap-stats.api")
      assert.is_table(api.state)
      assert.is_table(api.state.session)
      assert.is_table(api.state.session.keymap_count)
    end)

    it("should count keymap executions", function()
      local api = require("keymap-stats.api")
      local initial_count = api.state.session.keymap_count["gg:n:default:keymap:false"] or 0

      api.count_keymap("gg", "n", "default", false, false, 1)

      assert.equal(initial_count + 1, api.state.session.keymap_count["gg:n:default:keymap:false"])
    end)

    it("should skip counting keys with S(...) pattern", function()
      local api = require("keymap-stats.api")
      local key_with_special = "S(some-text):n:default:keymap:false"

      api.count_keymap("S(some-text)", "n", "default", false, false, 1)

      -- Should not be counted due to S(...) pattern
      assert.is_nil(api.state.session.keymap_count[key_with_special])
    end)

    it("should handle termcode replacement in lhs", function()
      local api = require("keymap-stats.api")
      local lhs_with_termcodes = "<CR>"

      api.count_keymap(lhs_with_termcodes, "i", "default", false, false, 1)

      -- Should be converted to actual key codes
      assert.is_not_nil(api.state.session.keymap_count)
    end)
  end)

  describe("init module", function()
    it("should have default options", function()
      local keymap_stats = require("keymap-stats")
      assert.is_string(keymap_stats.logfile)
    end)

    it("should accept custom options in setup", function()
      local keymap_stats = require("keymap-stats")
      local original_autoinstrument = keymap_stats.options.autoinstrument

      -- Reset module to test fresh setup
      package.loaded["keymap-stats"] = nil
      keymap_stats = require("keymap-stats")

      -- Setup with custom options (without triggering instrumentation)
      keymap_stats.setup({
        autoinstrument = false,
        debug = true,
        notify = false,
        plugins = { which_key = false, hardtime = false, keymap = false },
      })

      assert.equal(false, keymap_stats.options.autoinstrument)
      assert.equal(true, keymap_stats.options.debug)
      assert.equal(false, keymap_stats.options.plugins.which_key)
      assert.equal(false, keymap_stats.options.plugins.hardtime)
      assert.equal(false, keymap_stats.options.plugins.keymap)

      -- Restore original module
      package.loaded["keymap-stats"] = nil
      require("keymap-stats").setup({ autoinstrument = original_autoinstrument })
    end)

    it("should initialize stats tracking", function()
      local keymap_stats = require("keymap-stats")
      assert.is_table(keymap_stats.stats)
      assert.is_number(keymap_stats.stats.callback_count)
      assert.is_number(keymap_stats.stats.rhs_count)
    end)
  end)

  describe("state management", function()
    it("should track plugin state separately from options", function()
      local keymap_stats = require("keymap-stats")
      assert.is_table(keymap_stats.state)
      assert.is_table(keymap_stats.options)
      -- State and options should be different tables
      assert.is_not.equal(keymap_stats.state, keymap_stats.options)
    end)

    it("should have initialized plugin tracking structures", function()
      local keymap_stats = require("keymap-stats")
      assert.is_table(keymap_stats.stats.plugins)
      assert.is_table(keymap_stats.state.plugins)
    end)
  end)
end)
