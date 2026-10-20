-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
return {
  {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.nvim' }, -- if you use the mini.nvim suite
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-mini/mini.icons' },        -- if you use standalone mini plugins
    -- dependencies = { 'nvim-treesitter/nvim-treesitter', 'nvim-tree/nvim-web-devicons' }, -- if you prefer nvim-web-devicons
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
  },

  -- NOTE:
  -- Mermaid is previewed in the browser, because Alacritty cannot show images, so no plugin can draw a diagram here.
  --
  -- previm runs no server: it writes a page, opens it as a file, and the page reloads the rendered text by itself.
  --
  -- The page goes under the cache directory instead of into previm's own checkout, and previm removes it on exit.
  {
    'previm/previm',
    ft = 'markdown',
    init = function()
      vim.g.previm_open_cmd = 'open'
      vim.g.previm_enable_realtime = 1
      vim.g.previm_custom_preview_base_dir = vim.fn.stdpath 'cache' .. '/previm'
    end,
  },
}
