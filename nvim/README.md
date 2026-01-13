# Neovim Configuration (Omakub-inspired)

This Neovim configuration is based on [Omakub](https://github.com/basecamp/omakub) by DHH/Basecamp - an opinionated Ubuntu setup with a beautifully configured LazyVim.

## What's Included

This is a **LazyVim** configuration with Omakub's specific customizations:

- ✅ **Tokyo Night** color scheme
- ✅ **Transparent background** (terminal background shows through)
- ✅ **No animated scrolling** (snappier feel)
- ✅ **Absolute line numbers** (no relative numbering)
- ✅ **Neo-tree** file explorer by default
- ✅ **Full LSP support** (language servers, completion, diagnostics)
- ✅ **Treesitter** syntax highlighting
- ✅ **Telescope** fuzzy finder
- ✅ **Git integration** (LazyGit, Gitsigns)

## Structure

```
nvim/
├── init.lua                                  # Entry point
├── lazyvim.json                              # LazyVim config (enables neo-tree)
├── lua/
│   ├── config/
│   │   ├── autocmds.lua                     # Auto-commands
│   │   ├── keymaps.lua                      # Key mappings
│   │   ├── lazy.lua                         # Plugin manager bootstrap
│   │   └── options.lua                      # Vim options (relative numbers off)
│   └── plugins/
│       ├── theme.lua                        # Tokyo Night theme
│       └── snacks-animated-scrolling-off.lua # Disable scroll animations
└── plugin/
    └── after/
        └── transparency.lua                  # Terminal transparency
```

## First Launch

When you first run `nvim`:
1. Lazy.nvim plugin manager bootstraps automatically
2. LazyVim and all plugins download (~1-2 minutes)
3. Language servers install automatically
4. Everything "just works" ™️

**Be patient during first launch!**

## Key Bindings (Leader = Space)

### Essential LazyVim Commands

- `<Space>ff` - Find files (Telescope)
- `<Space>fg` - Live grep (search in all files)
- `<Space>e` - Toggle Neo-tree file explorer
- `<Space>gg` - Open LazyGit
- `<Space>qq` - Quit all

### Navigation

- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation
- `<Space>ca` - Code actions
- `<Space>rn` - Rename symbol

### Editing

- `gcc` - Comment/uncomment line
- `gc` (visual) - Comment/uncomment selection
- `<C-/>` - Toggle terminal

### Window Management

- `<C-h/j/k/l>` - Navigate between splits
- `<C-Up/Down/Left/Right>` - Resize splits

## Customization

### Disable Transparency

If you don't want a transparent background, delete:
```bash
rm ~/.dotfiles/nvim/plugin/after/transparency.lua
```

### Change Theme

Edit `lua/plugins/theme.lua`:
```lua
colorscheme = "catppuccin"  -- or "gruvbox", "nord", etc.
```

### Add Plugins

Create a new file in `lua/plugins/`:
```lua
-- lua/plugins/my-plugin.lua
return {
  {
    "username/plugin-name",
    event = "VeryLazy",
    opts = {},
  },
}
```

### Enable Relative Line Numbers

Remove or comment out in `lua/config/options.lua`:
```lua
-- vim.opt.relativenumber = false
```

## Health Check

Run `:checkhealth` in Neovim to verify everything works.

## Learn More

- [LazyVim Documentation](https://www.lazyvim.org/)
- [LazyVim Keymaps](https://www.lazyvim.org/keymaps)
- [Omakub Project](https://github.com/basecamp/omakub)
- [The Omarchy Manual](https://learn.omacom.io/2/the-omarchy-manual)

## Credits

Configuration inspired by [Omakub](https://github.com/basecamp/omakub) - DHH's opinionated Ubuntu setup.
