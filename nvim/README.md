# LazyVim Configuration

This directory contains your Neovim configuration using [LazyVim](https://www.lazyvim.org/).

## Structure

```
nvim/
├── init.lua                    # Entry point
├── lua/
│   ├── config/
│   │   ├── autocmds.lua       # Auto commands
│   │   ├── keymaps.lua        # Key mappings
│   │   ├── lazy.lua           # Plugin manager setup
│   │   └── options.lua        # Vim options
│   └── plugins/
│       └── example.lua        # Plugin configurations
└── lazy-lock.json             # Plugin lockfile (auto-generated, gitignored)
```

## First Launch

When you first run `nvim`, LazyVim will:
1. Bootstrap lazy.nvim plugin manager
2. Download and install LazyVim
3. Install all default plugins
4. Set up language servers (LSP)

This takes 1-2 minutes. Be patient!

## Key Bindings (Leader = Space)

### Essential
- `<leader>ff` - Find files
- `<leader>fg` - Live grep (search in files)
- `<leader>e` - Toggle file explorer
- `<leader>qq` - Quit all

### Window Management
- `ss` - Split horizontally
- `sv` - Split vertically
- `sh/sj/sk/sl` - Move between splits

### Editing
- `<C-s>` - Save file
- `gcc` - Toggle comment line
- `gc` - Toggle comment (visual mode)

### LSP
- `gd` - Go to definition
- `gr` - Find references
- `K` - Show hover documentation
- `<leader>ca` - Code actions
- `<leader>rn` - Rename symbol

## Adding Plugins

Create a new file in `lua/plugins/`:

```lua
-- lua/plugins/my-plugin.lua
return {
  {
    "username/plugin-name",
    event = "VeryLazy",
    opts = {
      -- plugin options
    },
  },
}
```

## Customizing

- **Options**: Edit `lua/config/options.lua`
- **Keymaps**: Edit `lua/config/keymaps.lua`
- **Plugins**: Add files to `lua/plugins/`
- **Autocmds**: Edit `lua/config/autocmds.lua`

## Health Check

Run `:checkhealth` in Neovim to verify everything is working correctly.

## Learn More

- [LazyVim Docs](https://www.lazyvim.org/)
- [Keymaps Reference](https://www.lazyvim.org/keymaps)
- [Plugin List](https://www.lazyvim.org/plugins)
