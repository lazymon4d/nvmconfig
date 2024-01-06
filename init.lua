local config_dir = vim.fn.stdpath('config')

-- extend paths and cpaths to make init file more modular
package.path = package.path .. ";" .. config_dir .. "/?.lua"

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    print('Installing lazy.nvim....')
    vim.fn.system({
      'git',
      'clone',
      '--filter=blob:none',
      'https://github.com/folke/lazy.nvim.git',
      '--branch=stable', -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  -- You can "comment out" the line below after lazy.nvim is installed
  lazy.install(lazy.path)

  vim.opt.rtp:prepend(lazy.path)

  require('lazy').setup(plugins, lazy.opts)
  vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath('data') .. '/lazy/lazy.nvim'
lazy.opts = {}

lazy.setup({
  {"neovim/nvim-lspconfig"},
  {"folke/tokyonight.nvim"},
  {"nvim-lualine/lualine.nvim"},
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    build = "make install_jsregexp"
  },
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    }
  },
  {"hrsh7th/cmp-nvim-lsp"},
  {"hrsh7th/cmp-buffer"},
  {"hrsh7th/cmp-path"},
  {"hrsh7th/cmp-cmdline"},
  {"hrsh7th/nvim-cmp"},
})

require("lualine").setup()
require("nvim-tree").setup()

local luasnip = require("luasnip")
-- require("snippets.SnipLoader").LoadSnippets(luasnip, { cpp = config_dir .. "/snippets/cpp/" })

local cmp = require("cmp")

cmp.setup({
  snippet = {
    expand = function(args)
     luasnip.lsp_expand(args.body) -- For `luasnip` users.
    end,
  },
  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-b>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.abort(),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
  }),
  sources = cmp.config.sources({
      { name = 'nvim_lsp' },
      { name = 'luasnip' }, -- For luasnip users.
    }, {
      { name = 'buffer' },
  }),
})

-- Set configuration for specific filetype.
cmp.setup.filetype('gitcommit', {
  sources = cmp.config.sources(
    {
      { name = 'git' },
    }, 
    {
      { name = 'buffer' },
    }
  )
})

cmp.setup.cmdline({ '/', '?' }, {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})


local capabilities = require('cmp_nvim_lsp').default_capabilities()

require("lspconfig").clangd.setup {
  cmd = { "clangd", "--background-index" },
  filetypes = { "c", "cpp", "cxx", "cc", "hpp", "h" },
  capabilities = capabilities,
}

require("lspconfig").rust_analyzer.setup({
  on_attach = function(client)
    require'completion'.on_attach(client)
  end,
  settings = {
    ["rust-analyzer"] = {
      imports = {
        granularity = {
          group = "module",
        },
        prefix = "self",
      },
      cargo = {
        buildScripts = {
          enable = true,
        },
      },
      procMacro = {
        enable = true
      },
    }
  },
})

vim.opt.termguicolors = true
vim.cmd.colorscheme("tokyonight")

-- Set tab-related options
vim.o.tabstop = 2      -- Number of spaces a tab counts for
vim.o.softtabstop = 2  -- Number of spaces to use when editing (insert mode)
vim.o.shiftwidth = 2   -- Number of spaces for autoindent

-- Use spaces instead of tabs
vim.o.expandtab = true

-- Always show line numbers
vim.o.number = true
