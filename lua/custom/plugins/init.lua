-- You can add your own plugins here or in other files in this directory!
--  I promise not to create any merge conflicts in this directory :)
--
-- See the kickstart.nvim README for more information
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', 'grq', vim.lsp.buf.hover, { desc = 'Show Documentation' })

return {
  {
    'nvim-tree/nvim-tree.lua',
    config = function()
      require('nvim-tree').setup {
        sort = {
          sorter = 'case_sensitive',
        },
        view = {
          width = 35,
        },
        renderer = {
          group_empty = true,
        },
        filters = {
          git_ignored = false,
        },
      }

      local api = require 'nvim-tree.api'
      vim.keymap.set('n', '<leader>tf', api.tree.toggle, { desc = '[T]oggle File Tree' })
      vim.keymap.set('n', '<leader>ff', function()
        api.tree.find_file()
        api.tree.focus()
      end, { desc = '[F]ind current buffer in FileTree' })
    end,
  },
  {
    'akinsho/toggleterm.nvim',
    version = '*',
    config = function()
      require('toggleterm').setup {
        open_mapping = '<leader>tt',
      }
    end,
  },
}
