-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.g.clipboard = {
  name = 'DankClipboard',
  copy = {
    ['+'] = 'dms cl copy',
    ['*'] = 'dms cl copy',
  },
  paste = {
    ['+'] = 'dms cl paste',
    ['*'] = 'dms cl paste',
  },
  cache_enabled = 0,
}
