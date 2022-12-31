# tidal.nvim

(very) minimal, opinionated filetype plugin for [TidalCycles](https://tidalcycles.org),
written in Lua.
There is no reason to prefer this plugin to [vim-tidal](https://github.com/tidalcycles/vim-tidal).

## Installation

```lua
-- packer.nvim
use 'ryleelyman/tidal.nvim'
```

## Requirements

To use the `send_node` mapping,
which is based on [treesitter](https://github.com/nvim-treesitter/nvim-treesitter),
you must have the treesitter parser for `haskell` installed.

## Configuration

To use `tidal.nvim`, you must have the following somewhere in your config.

```lua
require('tidal').setup()
```

This is equivalent to the following default configuration.

```lua
require('tidal').setup{
    boot = {
        tidal = {
            file = vim.api.nvim_get_runtime_file("BootTidal.hs", false)[1],
            args = {},
        },
        sclang = {
            file = vim.api.nvim_get_runtime_file("BootSuperDirt.scd", false)[1],
            enabled = false,
        },
        split = 'v',
    },
    keymaps = {
        send_line = "<C-L>",
        send_node = "<Leader>s",
        send_visual = "<C-L>",
        hush = "<C-H>"
    }
}
```

### Boot

`tidal.nvim` provides a pair of `Ex` commands,
`:TidalLaunch` and `:TidalExit`,
which start and stop TidalCycles processes.
By default, only a session of `ghci` running the `BootTidal.hs` script provided by this plugin is run.

If `boot.sclang.enabled` is `true`, then a session of `sclang` is run.
Please ensure that the command `sclang` correctly starts an instance of SuperCollider when executed in the terminal.
By default on macOS, this appears to require something like the following
shell script saved as `sclang` someplace in your path.

```sh
#!/bin/sh
cd /Applications/SuperCollider.app/Contents/MacOS
./sclang "$@"
```

### Keymaps

`tidal.nvim` provides four configurable keymaps in `.tidal` files,
which are used to send chunks of TidalCycles code from the file to the Tidal interpreter.
`send_line` sends the current line,
`send_node` sends the largest tree-sitter node containing the current line,
`send_visual` sends the current visual selection,
and `hush` sends "hush".
