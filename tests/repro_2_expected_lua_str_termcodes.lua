-- Repro for: https://github.com/gmatheu/keymap-stats.nvim/issues/1
vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

vim.opt.rtp:prepend(".")

vim.g.mapleader = ","
vim.g.maplocalleader = " "
-- Enable number and relative number
vim.opt.number = true
vim.opt.relativenumber = true

vim.keymap.set("n", "<Leader>,", "<cmd> :e#<CR>", { desc = "Switch Last buffer" })
vim.keymap.set("n", "<Leader>ss", "<cmd>KeymapStats session<CR>", { desc = "Shor current session stats" })

-- Setup lazy.nvim
require("lazy.minit").repro({
  spec = {
    {
      "folke/snacks.nvim",
      version = "*",
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
        },
      },
    },
    {
      dir = vim.uv.cwd(),
      opts = {
        autoinstrument = true,
        plugins = { which_key = false, hardtime = false, keymap = true },
        debug = false,
        very_verbose = false,
        notify = true,
        include_rhs = false,
      },
      event = "VeryLazy",
      dependencies = {
        { "MunifTanjim/nui.nvim" },
        { "anuvyklack/keymap-amend.nvim" },
      },
    },
  },
})
