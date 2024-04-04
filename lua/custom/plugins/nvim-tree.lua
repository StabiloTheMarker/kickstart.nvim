return {
  'nvim-tree/nvim-tree.lua',
  config = function()
    require('nvim-tree').setup()
    local api = require 'nvim-tree.api'
    vim.keymap.set('n', '<A-1>', api.tree.toggle)
    vim.keymap.set('n', '<A-f>', function()
      api.tree.find_file()
      api.tree.open()
    end)
  end,
}
