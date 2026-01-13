-- Example plugin configurations
-- Add your own plugins here or create separate files in this directory

return {
  -- Change theme
  {
    "LazyVim/LazyVim",
    opts = {
      colorscheme = "tokyonight",
    },
  },

  -- Add or customize plugins by adding them here
  -- Example: Add a plugin
  -- {
  --   "folke/flash.nvim",
  --   event = "VeryLazy",
  --   opts = {},
  --   keys = {
  --     {
  --       "s",
  --       mode = { "n", "x", "o" },
  --       function()
  --         require("flash").jump()
  --       end,
  --       desc = "Flash",
  --     },
  --   },
  -- },

  -- Disable a default plugin
  -- { "folke/tokyonight.nvim", enabled = false },
}
