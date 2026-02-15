-- Repro for: https://github.com/gmatheu/keymap-stats.nvim/issues/1
vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

vim.opt.rtp:prepend(".")

vim.g.mapleader = ","
vim.g.maplocalleader = " "
-- Enable number and relative number
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.nomore = true

vim.keymap.set("n", "<Leader>,", "<cmd> :e#<CR>", { desc = "Switch Last buffer" })
vim.keymap.set("n", "<Leader>ss", "<cmd>KeymapStats session<CR>", { desc = "Show current session stats" })

-- Setup lazy.nvim
require("lazy.minit").repro({
  spec = {
    {
      "folke/snacks.nvim",
      version = "*",
      lazy = true,
      opts = {
        notifier = { enabled = true },
      },
      keys = {
        {
          "<LocalLeader>c",
          function()
            vim.notify("Test action")
          end,
          mode = { "n", "v" },
          desc = "DESC LOCAL LEADER",
        },
        {
          "<Leader>c",
          function()
            vim.notify("Test action")
          end,
          mode = { "n", "v" },
          desc = "DESC LEADER",
        },
      },
    },
    {
      dir = vim.uv.cwd(),
      opts = {
        autoinstrument = true,
        plugins = { which_key = false, hardtime = false, keymap = true },
        debug = true,
        very_verbose = true,
        notify = true,
        include_rhs = false,
      },
      event = "VeryLazy",
      dependencies = {
        { "MunifTanjim/nui.nvim" },
        { "gmatheu/keymap-amend.nvim" },
      },
    },
  },
})

local lazyState = {
  count = 0,
  veryLazyTriggered = false,
  veryLazyCount = 0,
}
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyDone",
  callback = function()
    vim.notify("LazyDone")
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    vim.notify("LazyVimStarted")
  end,
})

vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    vim.notify("Very Lazy")
    lazyState.veryLazyTriggered = true
  end,
})
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyLoad",
  callback = function(args)
    lazyState.count = lazyState.count + 1
    if lazyState.veryLazyTriggered then
      lazyState.veryLazyCount = lazyState.veryLazyCount + 1
      vim.notify(
        "Plugin loaded (" .. lazyState.veryLazyCount .. "/" .. lazyState.count .. "): " .. vim.inspect(args.data)
      )
      local plugin = require("lazy.core.config").plugins[args.data]
      vim.notify("Plugin: " .. vim.inspect(plugin._.handlers.keys))
      require("keymap-stats.plugins.keymap").setup()
    else
      vim.notify("Plugin loaded (" .. lazyState.count .. "): " .. vim.inspect(args.data))
    end
  end,
})
