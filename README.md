# Notify.nvim

An floating notification plugin for Neovim.

## Installation

Using [Lazy](https://github.com/folke/lazy.nvim):

```lua
{
    "michel-garcia/notify.nvim",
    opts = {
        border = nil,
        hl_groups = {
            [vim.log.levels.ERROR] = "DiagnosticError",
            [vim.log.levels.WARN] = "DiagnosticWarn",
            [vim.log.levels.INFO] = "DiagnosticInfo",
            [vim.log.levels.DEBUG] = "DiagnosticHint",
            [vim.log.levels.TRACE] = "DiagnosticOk",
        },
        max = 4,
        override = true,
        placement = "bottom-right",
        spacing = 1,
        timeout = 3000,
        width = 64,
        zindex = 999,
    },
}
```

## Usage

```lua
require("notify").notify("Lsp Progress", vim.log.levels.INFO, {
    icon = "#",
    id = "progress",
    timeout = 3000,
    title = "Lsp"
})
```
