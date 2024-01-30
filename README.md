**USE AT YOUR OWN RISK**

# Spotter

A Neovim plugin to easily spot the targets for f/t/F/T motions!

## Installation

With lazy.nvim it looks like this:
```lua
require('lazy').setup({{
    'herrvonvoid/spotter',
    config = function()
        require('spotter').setup()
    end
}})
```

## Usage

Spotter comes with default mappings for the f/t/F/T motions. You can
customized how the highlights look in the config.

To create custom mappings, these use-case functions are exposed:

* `disable_default_maps()` and `enable_default_maps()`
* `show()` show the targets and hide them again once you are done:
  + show all targets (default), or only show the ones for f/t
    (`where='after'`) or F/T (`where='before'`)
  + by default hides on cursor movement; suppress this with
    `hide_on_move=false` or by using `expire_ms` (see below)
  + the targets are toggled if `toggle=true` is used 
  + hide after `expire_ms=5000` milliseconds. Note, that the targets
    will not be hidden during operator pending mode! If the timer
    expires during this time, the targets are hidden immediately
    afterwards.
  + using both `expire_ms` and `hide_on_move` hides the targets on the
    sooner condition (but not during operator pending mode!)
* `hide_on_move()` can be used in custom functions
* `hide_on_expire()` can be used in custom functions. Passing
  `hide_on_move=true` also hides the targets on cursor movement,
  whatever, comes first. Note, that targets are never hidden during
  operator pending mode.

`core.lua` exposes a function to check whether targets are currently
shown, one to activate the highlights and one to remove them.

For simple control over the highlighting behaviour config options are
available.

## Configuration

```lua
require('spotter').setup{
    -- Activate the default mappings on setup() ?
    use_default_maps = true,
    -- Dim the line?
    dim_line = true,
    -- Highlight group for dimming the line
    color_dim_line = 'Comment',
    -- Highlight group for highlighting the targets
    color_targets = 'Search',

    -- Do you need some custom behaviour when showing the targets? For
    -- example temporarily deactivating 'cursorline'? You can inject
    -- this behaviour here. The functions receive the argument of the
    -- use-case function, so you can use any key not used by Spotter
    -- itself to compose conditional behaviour depending on how the
    -- function was called.
    inject_on_show = function(opts) vim.wo.cursorline = false end,
    inject_on_hide = function(opts) vim.wo.cursorline = true end,
}

-- create a custom mapping
vim.keymap.set( -- just show the targets for some seconds:
    {'n', 'v'},
    '<leader>g',
    "<Cmd>lua require'spotter'.show{expire_ms=5000, hide_on_move=true, toggle=true}<CR>",
    {remap=false}
)
```
