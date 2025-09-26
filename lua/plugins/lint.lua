return {
  {
    'mfussenegger/nvim-lint',
    event = { 'BufReadPre', 'BufNewFile' },
    config = function()
      local lint = require 'lint'

      lint.linters_by_ft = {
        markdown = { 'markdownlint' },
      }

      local ts_like = {
        typescript = true,
        typescriptreact = true,
        javascript = true,
        javascriptreact = true,
        vue = true,
        svelte = true,
      }

      local function has_any(bufnr, names)
        local file = vim.api.nvim_buf_get_name(bufnr)
        if file == '' then return false end
        local start = vim.fs.dirname(file)
        if not start then return false end
        local found = vim.fs.find(names, { upward = true, path = start })
        return #found > 0
      end

      local function select_ts_linter(bufnr)
        if has_any(bufnr, { 'biome.json', 'biome.jsonc' }) then
          return 'biome'
        end
        local prettier_markers = {
          '.prettierrc', '.prettierrc.js', '.prettierrc.cjs', '.prettierrc.mjs',
          '.prettierrc.json', '.prettierrc.yml', '.prettierrc.yaml', '.prettierrc.toml',
          'prettier.config.js', 'prettier.config.cjs', 'prettier.config.mjs',
        }
        if has_any(bufnr, prettier_markers) then
          if vim.fn.executable('eslint_d') == 1 then
            return 'eslint_d'
          else
            return 'eslint'
          end
        end
        if vim.fn.executable('eslint_d') == 1 then
          return 'eslint_d'
        else
          return 'eslint'
        end
      end

      local lint_augroup = vim.api.nvim_create_augroup('lint', { clear = true })
      vim.api.nvim_create_autocmd({ 'BufEnter', 'BufWritePost', 'InsertLeave' }, {
        group = lint_augroup,
        callback = function(args)
          if not vim.bo.modifiable then return end
          local ft = vim.bo[args.buf].filetype
          if ts_like[ft] then
            local l = select_ts_linter(args.buf)
            if l then
              lint.try_lint(l)
              return
            end
          end
          lint.try_lint()
        end,
      })
    end,
  },
}
