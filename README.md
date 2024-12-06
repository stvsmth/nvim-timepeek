# timepeek

**timepeek** is a Neovim plugin to display Unix timestamps as human-readable dates in UTC and the
local timezone.

## Installation

Using [packer.nvim](https://github.com/wbthomason/packer.nvim):
```lua
use 'stvsmth/nvim-timepeek'
```

Using [vim-plug](https://github.com/junegunn/vim-plug):
```vim
Plug 'stvsmth/nvim-timepeek'
```

## Usage

Place the cursor on a Unix timestamp and press `<Leader>tt` to display the date in a floating
window. While inside the floating window, you can dismiss it by pressing the `return` key or the
`esc` key. You can also use standard vim motion commands to select one of the date strings and yank
it to a register.

The floating window adheres to standard Neovim window management commands. In particular, if you
navigate out of the floating window, you can use commands like `CTRL-W w` to switch windows so that
you can dismiss the floating window. See `:help windows` for more information. 

### Customizing the keybinding

TL;DR, more coming.

```
<Cmd>lua require('timepeek').render_date()<CR>
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

