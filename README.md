# timepeek

**timepeek** is a Neovim plugin to display Unix timestamps as human-readable dates in UTC and the
local timezone.

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):
```lua
{
  'stvsmth/nvim-timepeek',
  config = function()
    require('timepeek').setup()
  end
}
```

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use {
  'stvsmth/nvim-timepeek',
  config = function() require('timepeek').setup() end
}
```

Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'stvsmth/nvim-timepeek'
```
Then add to your init.lua:
```lua
require('timepeek').setup()
```

## Configuration

Configure `timepeek` by passing a table to the setup function. Here's the default configuration:

```lua
require('timepeek').setup({
  -- Enable/disable default keymaps
  use_default_mappings = true,
  -- Keymap definitions
  mappings = {
    peek = "<Leader>tt"
  },
  -- Window appearance
  window = {
    border = 'rounded',
    style = "minimal",
    relative = "cursor",
    row = 1,
    col = 0
  },
  -- Date formats
  formats = {
    utc = "!%Y-%m-%d %H:%M:%S UTC",
    local_time = "%Y-%m-%d %H:%M:%S %Z"
  }
})
```

### Custom Configuration Examples

Disable default mapping and set custom formats:
```lua
require('timepeek').setup({
  use_default_mappings = false,
  formats = {
    utc = "!%a, %d %b %Y %H:%M:%S UTC",
    local_time = "%a, %d %b %Y %H:%M:%S %Z"
  }
})

-- Add your own keymapping
vim.keymap.set('n', '<Leader>tp', require('timepeek').render_date, {})
```

## Usage

Place the cursor on a Unix timestamp and press `<Leader>tt` (or your custom keybinding) to display
the date in a floating window. While inside the floating window, you can dismiss it by pressing the
`return` key or the `esc` key. You can also use standard vim motion commands to select one of the
date strings and yank it to a register.

The floating window adheres to standard Neovim window management commands. In particular, if you
navigate out of the floating window, you can use commands like `CTRL-W w` to switch windows so that
you can dismiss the floating window. See `:help windows` for more information.

### API

The plugin exposes the following functions:

```lua
-- Display a date window for the timestamp under the cursor
require('timepeek').render_date()

-- Configure the plugin
require('timepeek').setup(options)
```

## Example / Screenshot

```json
{
  "comment": "That was a long wait",
  "timestamp": 1098938400
}
```

Invoking `timepeek` with the cursor on `1098938400` will display:

![timepeek_usage_example](https://github.com/user-attachments/assets/f45a4f3a-3ccd-4118-b632-a9d248259953)
