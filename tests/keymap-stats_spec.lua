describe("keymap-stats plugin", function()
  describe("keymap plugin module", function()
    it("should instrument keymaps with default opts", function()
      local api = require("keymap-stats.api")
      local keymap = require("keymap-stats.plugins.keymap")
      keymap.setup(api.count, api.count_keymap, true, {})

      assert.is_true(keymap.state.instrumented)
      assert.is_not_nil(keymap.stats.included_lhs)
    end)

    -- it("should have lots of features", function()
    --   -- deep check comparisons!
    --   assert.same({ table = "great" }, { table = "great" })
    --
    --   -- or check by reference!
    --   assert.is_not.equals({ table = "great" }, { table = "great" })
    --
    --   assert.falsy(nil)
    --   assert.error(function()
    --     error("Wat")
    --   end)
    -- end)
    --
    -- it("should provide some shortcuts to common functions", function()
    --   assert.unique({ { thing = 1 }, { thing = 2 }, { thing = 3 } })
    -- end)
    --
    -- it("should have mocks and spies for functional tests", function()
    --   local thing = require("thing_module")
    --   spy.on(thing, "greet")
    --   thing.greet("Hi!")
    --
    --   assert.spy(thing.greet).was.called()
    --   assert.spy(thing.greet).was.called_with("Hi!")
    -- end)
  end)
end)
