-- ── Leader key (before lazy) ──────────────────────────────────────────────
vim.g.mapleader 		= ' '
vim.g.maplocalleader	= ' '

-- ── Core options ──────────────────────────────────────────────────────────
local opt 				= vim.opt
opt.number 				= true
opt.relativenumber 		= true
opt.mouse				= 'a'
opt.clipboard			= 'unnamedplus'
opt.tabstop				= 4
opt.shiftwidth 			= 4
opt.expandtab			= true
opt.smartindent 		= true
opt.wrap                = false
opt.cursorline          = true
opt.termguicolors       = true
opt.signcolumn          = 'yes'
opt.scrolloff           = 8
opt.updatetime          = 250
opt.undofile            = true
opt.splitright          = true
opt.splitbelow          = true
opt.ignorecase          = true
opt.smartcase           = true
opt.showmode            = false
opt.colorcolumn         = '100'
opt.spell               = true
opt.spelllang           = { "en_ca" }

-- ── Bootstrap lazy.nvim ───────────────────────────────────────────────────
local lazypath = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    'git', 'clone', '--filter=blob:none',
    'https://github.com/folke/lazy.nvim.git',
    '--branch=stable', lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- ── Plugins ───────────────────────────────────────────────────────────────
require('lazy').setup({
    -- Theme (GitHub)
    {
        'projekt0n/github-nvim-theme',
        name = 'github-theme',
        lazy = false,
        priority = 1000,
	    config = function()
	        require('github-theme').setup({})
            vim.cmd('colorscheme github_dark')
    	end,
    },

    -- File explorer
    {
      'stevearc/oil.nvim',
      config = function()
        require('oil').setup({ view_options = { show_hidden = true } })
      end,
    },

    -- Auto pair
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = true
    },

    -- Fuzzy finder
    {
      'nvim-telescope/telescope.nvim', version = '*',
      dependencies = {
          'nvim-lua/plenary.nvim',
          { 'nvim-telescope/telescope-fzf-native.nvim', build = 'make' },
      },
    },

    -- Status line
    {
      'nvim-lualine/lualine.nvim',
      config = function()
        require('lualine').setup({
          options = {
            icons_enabled = false,
            section_separators = '',
            component_separators = '|',
          },
        })
      end,
    },

    {
        'akinsho/bufferline.nvim',
        version = '*',
        config = function()
          require('bufferline').setup({
            options = {
              show_buffer_icons = false,
              show_buffer_close_icons = false,
              separator_style = 'thin',
            },
          })
        end,
    },

    -- Treesitter
    {
      'nvim-treesitter/nvim-treesitter',
      build = ':TSUpdate',
      config = function()
        require('nvim-treesitter').setup({
          ensure_installed = {
            'rust', 'python', 'c', 'cpp',
            'typescript', 'tsx', 'javascript', 'html', 'css',
            'go', 'gomod', 'gosum',
            'lua', 'toml', 'json', 'yaml', 'markdown',
          },
        })
      end,
    },

    -- ── LSP ─────────────────────────────────────────────────────────────────
    {
        'neovim/nvim-lspconfig',
        dependencies = { 'saghen/blink.cmp' },
        config = function()
            local capabilities = require('blink.cmp').get_lsp_capabilities()

            -- Rust
            vim.lsp.config('rust_analyzer', {
                capabilities = capabilities,
                settings = {
                    ['rust-analyzer'] = {
                        check = { command = 'clippy' },
                        cargo = { allFeatures = true },
                    },
                },
            })

            -- Python: npm install -g pyright
            vim.lsp.config('pyright', {
                capabilities = capabilities,
                settings = {
                    python = { analysis = { typeCheckingMode = 'basic' } },
                },
            })

            -- C/C++
            vim.lsp.config('clangd', {
                capabilities = capabilities,
            })

            -- TS/JS: npm install -g typescript-language-server typescript
            vim.lsp.config('ts_ls', {
                capabilities = capabilities,
            })

            -- HTML: npm install -g vscode-langservers-extracted
            vim.lsp.config('html', {
                capabilities = capabilities,
            })

            -- CSS: (same as HTML)
            vim.lsp.config('cssls', {
                capabilities = capabilities,
            })

            vim.lsp.enable('rust_analyzer')
            vim.lsp.enable('pyright')
            vim.lsp.enable('clangd')
            vim.lsp.enable('ts_ls')
            vim.lsp.enable('html')
            vim.lsp.enable('cssls')
    	end,
    },
    
    -- Completion
    {
        'saghen/blink.cmp',
        version = '1.*',
        config = function()
            require('blink.cmp').setup({
                keymap = {
                    preset = 'none',
                    ['<Tab>']       = { 'insert_next', 'snippet_forward', 'fallback' },
                    ['<S-Tab>']     = { 'insert_prev', 'snippet_backward', 'fallback' },
                    ['<C-Space>']   = { 'show' },
                    ['<C-e>']       = { 'cancel' },
                    ['<C-d>']       = { 'scroll_documentation_down' },
                    ['<C-u>']       = { 'scroll_documentation_up' },
                },
                completion = {
                    documentation = { auto_show = true },
                    list = { selection = { preselect = false, auto_insert = true } },
                    menu = {
                        draw = {
                            columns = { { "label" } },
                        }
                    },
                },
                sources = {
                    default = { 'lsp', 'path', 'snippets', 'buffer' },
                },
            })
        end,
    },

    -- Format on save
    {
      'stevearc/conform.nvim',
      config = function()
        require('conform').setup({
          formatters_by_ft = {
            rust       = { 'rustfmt' },
            python     = { 'ruff_format' },
            c          = { 'clang-format' },
            cpp        = { 'clang-format' },
            go         = { 'gofmt' },
            typescript = { 'prettierd', 'prettier', stop_after_first = true },
            javascript = { 'prettierd', 'prettier', stop_after_first = true },
            typescriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            javascriptreact = { 'prettierd', 'prettier', stop_after_first = true },
            html       = { 'prettierd', 'prettier', stop_after_first = true },
            css        = { 'prettierd', 'prettier', stop_after_first = true },
            json       = { 'prettierd', 'prettier', stop_after_first = true },
          },
          format_on_save = { timeout_ms = 1000, lsp_format = 'fallback' },
        })
      end,
    },
})

-- ── Keybindings ───────────────────────────────────────────────────────────
local map = vim.keymap.set

-- File explorer
map('n', '<leader>e',  '<cmd>Oil<CR>',                    { desc = 'File explorer' })

-- Buffers
map('n', '<S-l>',      '<cmd>bnext<CR>',                  { desc = 'Next buffer' })
map('n', '<S-h>',      '<cmd>bprev<CR>',                  { desc = 'Prev buffer' })
map('n', '<leader>bd', '<cmd>bdelete<CR>',                { desc = 'Delete buffer' })

-- LSP
vim.api.nvim_create_autocmd('LspAttach', {
  callback = function(ev)
    local o = { buffer = ev.buf }
    map('n', 'gd',         vim.lsp.buf.definition,    o)
    map('n', 'gD',         vim.lsp.buf.declaration,   o)
    map('n', 'gi',         vim.lsp.buf.implementation, o)
    map('n', 'gr',         vim.lsp.buf.references,    o)
    map('n', 'K',          vim.lsp.buf.hover,         o)
    map('n', '<leader>rn', vim.lsp.buf.rename,        o)
    map('n', '<leader>ca', vim.lsp.buf.code_action,   o)
    map('n', '<leader>d',  vim.diagnostic.open_float, o)
    map('n', '[d',         vim.diagnostic.goto_prev,  o)
    map('n', ']d',         vim.diagnostic.goto_next,  o)
  end,
})

-- Telescope
map('n', '<leader>ff', '<cmd>Telescope find_files<CR>',   { desc = 'Find files' })
map('n', '<leader>fg', '<cmd>Telescope live_grep<CR>',    { desc = 'Live grep' })
map('n', '<leader>fb', '<cmd>Telescope buffers<CR>',      { desc = 'Buffers' })
map('n', '<leader>fr', '<cmd>Telescope oldfiles<CR>',     { desc = 'Recent files' })
map('n', '<leader>fd', '<cmd>Telescope diagnostics<CR>',  { desc = 'Diagnostics' })

-- Move lines
map("n", "<A-j>", "<cmd>m .+1<CR>==")
map("n", "<A-k>", "<cmd>m .-2<CR>==")
map("v", "<A-j>", ":m '>+1<CR>gv=gv")
map("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- Keep selection after indent
map("v", "<", "<gv")
map("v", ">", ">gv")

map('n', ';;', ':%s:::g<Left><Left><Left>', { desc = 'Search and replace' })

