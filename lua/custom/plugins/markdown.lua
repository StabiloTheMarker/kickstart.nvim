return {
  {
    'iamcco/markdown-preview.nvim',
    ft = { 'markdown' },
    cmd = { 'MarkdownPreview', 'MarkdownPreviewStop', 'MarkdownPreviewToggle' },
    build = 'cd app && npx --yes yarn install',
    init = function()
      vim.g.mkdp_filetypes = { 'markdown' }
    end,
    keys = {
      {
        '<leader>rmt',
        function()
          vim.cmd 'MarkdownPreviewToggle'
        end,
        desc = '[M]arkdown Preview [T]oggle',
      },
      {
        '<leader>rmp',
        function()
          vim.cmd 'MarkdownPreview'
        end,
        desc = '[M]arkdown Preview [P]review',
      },
    },
  },
}
