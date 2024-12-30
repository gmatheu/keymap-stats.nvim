<!-- panvimdoc-ignore-start -->

<h1 align="center">
keymap-stats.nvim
</h1>

<p align="center">
<a href="https://github.com/gmatheu/keymap-stats.nvim/stargazers">
    <img
      alt="Stargazers"
      src="https://img.shields.io/github/stars/gmatheu/keymap-stats.nvim?style=for-the-badge&logo=starship&color=fae3b0&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/gmatheu/keymap-stats.nvim/issues">
    <img
      alt="Issues"
      src="https://img.shields.io/github/issues/gmatheu/keymap-stats.nvim?style=for-the-badge&logo=gitbook&color=ddb6f2&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
  <a href="https://github.com/gmatheu/keymap-stats.nvim/contributors">
    <img
      alt="Contributors"
      src="https://img.shields.io/github/contributors/gmatheu/keymap-stats.nvim?style=for-the-badge&logo=opensourceinitiative&color=abe9b3&logoColor=d9e0ee&labelColor=282a36"
    />
  </a>
</p>

<!-- <p align="center"> -->
<!--   <img src="https://github.com/gmatheu/keymap-stats.nvim/assets/<replace-with-screen-recording" width="700" /> -->
<!-- </p> -->

<!-- panvimdoc-ignore-end -->

## Introduction

A Neovim plugin to understand the usage of configured keymaps.

The goal is to have a better understanding of the usage of keymaps:

- Which are more frequently used.
- What is the common way to access keymaps.
- Which are never used.
  ...

Hopefully with that information, Neovim mappings can be optimized in your own configuration.

## Features

- Keeps usage of keymaps execution
- Keeps usage of which-key's windows (optional)
- Keeps usage of hardtime's hints [wip] (optional)
- Keeps usage of Telescopes's mappings winow [future] (optional)
- Keeps usage of commands executed [future] (optional)

## Requirements

- Neovim >= [v0.7.0](https://github.com/neovim/neovim/releases/tag/v0.7.0)

## 📦 Installation

1. Install via your favorite package manager.

```lua
-- lazy.nvim
{
   "gmatheu/keymap-stats.nvim",
   opts = {}
},
```

2. Setup the plugin in your `init.lua`. This step is not needed with lazy.nvim if `opts` is set as above.

```lua
require("keymap-stats").setup()
```

## Usage

- `:KeymapStats report` Show a report of all-time keymaps usage
- `:KeymapStats stats` Show some statistics of current keymaps settings

## Configuration

You can pass your config table into the `setup()` function or `opts` if you use lazy.nvim.

If the option is a boolean, number, or array, your value will overwrite the default configuration.

### Options

| Option Name | Type    | Default Valuae | Meaning                                                         |
| ----------- | ------- | -------------- | --------------------------------------------------------------- |
| `debug`     | boolean | `false`        | Debug mode (if enabled show notifications for multiple actions) |

<!-- Let's complete this table with the available options AI! -->

## References

Most of the code is "inspired" by these projects:

- [hardtime.nvim](https://github.com/m4xshen/hardtime.nvim)
- [which-key.nvim](https://github.com/folke/which-key.nvim)
- [lazy.nvim](https://github.com/folke/lazy.nvim)

####

Other tools:

- [luacheck](https://luacheck.readthedocs.io/en/stable/index.html)
