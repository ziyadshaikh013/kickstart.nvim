return {
  'stevearc/conform.nvim',
  event = { 'BufWritePre' },
  cmd = { 'ConformInfo' },
  keys = {
    {
      '<leader>f',
      function()
        require('conform').format { async = true, lsp_format = 'fallback' }
      end,
      mode = '',
      desc = '[F]ormat buffer',
    },
  },
  opts = {
    notify_on_error = false,
    format_on_save = function(bufnr)
      local disable_filetypes = { c = true, cpp = true }
      if disable_filetypes[vim.bo[bufnr].filetype] then
        return nil
      else
        return {
          timeout_ms = 500,
          lsp_format = 'fallback',
        }
      end
    end,
    formatters_by_ft = {
      lua = { 'stylua' },
      javascript = { 'biome', 'prettier' },
      javascriptreact = { 'biome', 'prettier' },
      typescript = { 'biome', 'prettier' },
      typescriptreact = { 'biome', 'prettier' },
    },
    formatters = {
      biome = {
        require_cwd = true, -- Enables automatic detection of biome.json or .biomerc
      },
      prettier = {
        require_cwd = true,
      },
    },
  },
}
