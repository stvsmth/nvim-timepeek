# timepeek

**timepeek** is a Neovim plugin to display Unix timestamps as human-readable dates in UTC and the
local timezone.

## Requirements

- Neovim >= 0.8.0

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

```viml
Plug 'stvsmth/nvim-timepeek'
```

Then add to your init.lua:

```lua
require('timepeek').setup()
```

## Features

- Convert Unix timestamps to human-readable dates in both UTC and local timezone
- Floating window display next to cursor
- Support for both second and millisecond timestamps
- Customizable date formats and window appearance
- Vim-like window navigation and text yanking support

## Configuration

Configure `timepeek` by passing a table to the setup function. Here's the default configuration:

```lua
require('timepeek').setup({
  -- Enable/disable default key maps
  use_default_mappings = true,
  -- Key map definitions
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

-- Add your own mapping
vim.keymap.set('n', '<Leader>tp', require('timepeek').render_date, {})
```

## Usage

Place the cursor on a Unix timestamp and press `<Leader>tt` (or your custom keybinding) to display
the date in a floating window. While inside the floating window, you can:

- Press `<CR>` or `<ESC>` to dismiss the window
- Use standard Vim motions to select and yank date strings
- Navigate between windows with `<C-w>w` and other window commands

The floating window follows standard Neovim window management commands. See `:help windows` for more information.

### API

The plugin exposes the following functions:

```lua
-- Display a date window for the timestamp under the cursor
require('timepeek').render_date()
```

## Example

```json
{
  "comment": "That was a long wait",
  "timestamp": 1098938400
}
```

Invoking `timepeek` with the cursor on `1098938400` will display:

![timepeek_usage_example](https://github.com/user-attachments/assets/f45a4f3a-3ccd-4118-b632-a9d248259953)

## Development

We use [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) for testing. Make sure you have it installed via your plugin manager of choice.

To run tests:

```bash
nvim --headless -c "PlenaryBustedDirectory tests"
```

## License

MIT License. See [LICENSE](LICENSE) for details.
