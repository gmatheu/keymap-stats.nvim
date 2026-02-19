vim.env.LAZY_STDPATH = ".tests"
load(vim.fn.system("curl -s https://raw.githubusercontent.com/folke/lazy.nvim/main/bootstrap.lua"))()

vim.opt.rtp:prepend(".")

vim.g.mapleader = ","
vim.g.maplocalleader = " "
-- Enable number and relative number
vim.opt.number = true

vim.opt.relativenumber = true

vim.keymap.set("n", "<Leader>,", "<cmd> :e#<CR>", { desc = "Switch Last buffer" })

-- Setup lazy.nvim
require("lazy.minit").repro({
  spec = {
    {
      "AstroNvim/AstroNvim",
      enabled = false,
      version = "^4", -- Remove version tracking to elect for nighly AstroNvim
      -- import = "astronvim.plugins",
      opts = { -- AstroNvim options must be set here with the `import` key
        mapleader = ",", -- This ensures the leader key must be configured before Lazy is set up
        maplocalleader = " ", -- This ensures the localleader key must be configured before Lazy is set up
        icons_enabled = true, -- Set to false to disable icons (if no Nerd Font is available)
        pin_plugins = nil,
      },
    },
    -- "williamboman/mason-lspconfig.nvim",
    -- "williamboman/mason.nvim",
    -- "nvim-treesitter/nvim-treesitter",
    {
      "nvim-telescope/telescope.nvim",
      enabled = true,
      tag = "0.1.8",
      config = function()
        local builtin = require("telescope.builtin")
        vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
        vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
        vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
        vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })

        require("telescope").load_extension("fzf")
      end,
      dependencies = {
        "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      },
    },
    {
      "folke/snacks.nvim",
      priority = 1000,
      lazy = false,
      opts = {
        scroll = {
          enabled = false,
        },
        bigfile = { enabled = true },
        quickfile = { enabled = true },
        statuscolumn = { enabled = true },
        words = { enabled = true },
        notifier = {
          enabled = true,
          timeout = 3000,
        },
      },
      keys = {
	  { "<leader>fk", function() Snacks.picker.keymaps() end, desc = "Keymaps" },
      }
    },
    { "m4xshen/hardtime.nvim", event="VeryLazy", },

      {
    "https://codeberg.org/andyg/leap.nvim",
    keys = {
      { "s", mode = { "n", "x", "o" }, desc = "Leap forward to" },
      { "S", mode = { "n", "x", "o" }, desc = "Leap backward to" },
      { "gs", mode = { "n", "x", "o" }, desc = "Leap from windows" },
    },
    config = function(_, opts)
      local leap = require "leap"
      for k, v in pairs(opts) do
        leap.opts[k] = v
      end
      leap.add_default_mappings(true)
      vim.keymap.del({ "x", "o" }, "x")
      vim.keymap.del({ "x", "o" }, "X")
    end,
  },



    {
      dir = vim.uv.cwd(),
      opts = {
        autoinstrument = true,
        plugins = { which_key = false, hardtime = false, keymap = true },
        debug = true,
        very_verbose = false,
        notify = false,
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
