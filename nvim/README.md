# LazyVim Configuration

This is the official [LazyVim](https://www.lazyvim.org/) starter template.

## What is LazyVim?

LazyVim is a Neovim setup powered by [💤 lazy.nvim](https://github.com/folke/lazy.nvim) to make it easy to customize and extend your config.

## Installation

The `setup.sh` script automatically symlinks this directory to `~/.config/nvim`.

On first launch of `nvim`, LazyVim will:
1. Bootstrap the lazy.nvim plugin manager
2. Download and install all plugins
3. Set up language servers (LSP)

**First launch takes 1-2 minutes** - be patient!

## Structure

```
nvim/
├── init.lua              # Entry point - bootstraps LazyVim
├── lua/
│   ├── config/
│   │   ├── autocmds.lua # Custom auto-commands
│   │   ├── keymaps.lua  # Custom key mappings
│   │   ├── lazy.lua     # Plugin manager configuration
│   │   └── options.lua  # Vim options
│   └── plugins/
│       └── example.lua  # Example plugin configurations (disabled by default)
├── .gitignore           # Git ignore patterns
├── .neoconf.json        # Neovim/LSP configuration
└── stylua.toml          # Lua formatter config
```

## Key Bindings

LazyVim uses `<Space>` as the leader key.

### Essential Commands

| Keys | Action |
|------|--------|
| `<Space>` | Show which-key menu |
| `<Space>ff` | Find files |
| `<Space>sg` | Search text (grep) |
| `<Space>e` | File explorer |
| `<Space>qq` | Quit all |

### Code Navigation

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `gr` | Find references |
| `K` | Hover documentation |
| `<Space>ca` | Code actions |
| `<Space>cr` | Rename symbol |

### Editing

| Keys | Action |
|------|--------|
| `gcc` | Comment/uncomment line |
| `gc` (visual) | Comment selection |
| `<C-/>` | Toggle terminal |

**Full keymaps**: Run `:help LazyVim` or visit [LazyVim Keymaps](https://www.lazyvim.org/keymaps)

## Customization

### Adding Plugins

Create a new file in `lua/plugins/` (e.g., `lua/plugins/my-plugins.lua`):

```lua
return {
  -- Add a plugin
  {
    "username/plugin-name",
    event = "VeryLazy",
    opts = {},
  },
}
```

### Changing Theme

Create `lua/plugins/colorscheme.lua`:

```lua
return {
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "catppuccin", -- or "gruvbox", "nord", etc.
    },
  },
}
```

### Custom Options

Edit `lua/config/options.lua`:

```lua
vim.opt.relativenumber = false  -- Disable relative line numbers
vim.opt.wrap = true            -- Enable line wrapping
```

### Custom Keymaps

Edit `lua/config/keymaps.lua`:

```lua
local map = vim.keymap.set

map("n", "<C-s>", ":w<CR>", { desc = "Save file" })
```

## Health Check

After first launch, run `:LazyHealth` to verify everything works correctly.

## Learn More

- [LazyVim Documentation](https://www.lazyvim.org/)
- [LazyVim GitHub](https://github.com/LazyVim/LazyVim)
- [Starter Template](https://github.com/LazyVim/starter)
- [Available Extras](https://www.lazyvim.org/extras)

## Troubleshooting

### Plugins not loading
Run `:Lazy sync` to reinstall all plugins.

### LSP not working
Run `:Mason` to manage language servers.

### Config issues
Run `:LazyHealth` to diagnose problems.

## Credits

- [LazyVim](https://github.com/LazyVim/LazyVim) by [folke](https://github.com/folke)
- [lazy.nvim](https://github.com/folke/lazy.nvim) plugin manager
