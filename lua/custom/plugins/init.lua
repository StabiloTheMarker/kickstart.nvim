-- You can add your own plugins here or in other files in this directory! I promise not to create any merge conflicts in this directory :) See the kickstart.nvim README for more information vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

if vim.loop.os_uname().sysname == 'Windows_NT' then
  -- Windows-specific shell (PowerShell)
  vim.opt.shell = 'powershell'
  vim.opt.shellcmdflag = '-NoLogo -NoProfile -ExecutionPolicy RemoteSigned -Command'
  vim.opt.shellquote = ''
  vim.opt.shellxquote = ''
end
-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', 'grq', vim.lsp.buf.hover, { desc = 'Show Documentation' })

return {
  {
    'greggh/claude-code.nvim',
    dependencies = {
      'nvim-lua/plenary.nvim', -- Required for git operations
    },
    config = function()
      require('claude-code').setup()
    end,
  },
  {
    'artemave/workspace-diagnostics.nvim',
    config = function()
      vim.api.nvim_set_keymap('n', '<leader>x', '', {
        noremap = true,
        callback = function()
          for _, client in ipairs(vim.lsp.get_clients()) do
            require('workspace-diagnostics').populate_workspace_diagnostics(client, 0)
          end
        end,
      })
    end,
  },
  {
    'nvim-pack/nvim-spectre',
    dependencies = { 'nvim-lua/plenary.nvim' },
    config = function()
      require('spectre').setup()

      -- Optional: Map <leader>fg to open Spectre
      vim.keymap.set('n', '<leader>fg', function()
        require('spectre').open()
      end, { desc = 'Open Spectre - Find and Replace' })
    end,
  },
  {
    'folke/flash.nvim',
    event = 'VeryLazy',
    ---@type Flash.Config
    opts = {},
  -- stylua: ignore
  keys = {
    { "s", mode= { "n", "x", "o" }, function() require("flash").jump() end, desc = "Flash" },
    { "<C-s>", mode = { "c" }, function() require("flash").toggle() end, desc = "Toggle Flash Search" },
  },
  },
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
        direction = 'float',
      }
    end,
  },
  {
    'windwp/nvim-autopairs',
    event = 'InsertEnter',
    config = true,
  },
  {
    'folke/zen-mode.nvim',
    config = function()
      require('zen-mode').setup {
        vim.keymap.set('n', '<leader>zen', '<cmd>ZenMode<CR>'),
        window = {
          width = 120, -- width of the focused code area
          options = {
            number = true,
            relativenumber = true,
          },
        },
      }
    end,
  },
}
