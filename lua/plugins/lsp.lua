-- ~/.config/nvim/lua/plugins/lsp.lua

-- LSP 관련 모든 플러그인과 설정을 담고 있는 파일입니다.
return {
  -- nvim-cmp: 자동 완성 플러그인 설정
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",      -- LSP 자동 완성 소스
      "hrsh7th/cmp-buffer",        -- 현재 버퍼 단어 자동 완성 소스
      "hrsh7th/cmp-path",          -- 파일 경로 자동 완성 소스
      "saadparwaiz1/cmp_luasnip",  -- cmp와 luasnip 연동
      "L3MON4D3/LuaSnip",          -- 스니펫 엔진
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        -- 자동 완성 소스 설정
        sources = {
          { name = "nvim_lsp" },
          { name = "luasnip" },
          { name = "buffer" },
          { name = "path" },
        },
        window = {
          completion = cmp.config.window.bordered(),
          documentation = cmp.config.window.bordered(),
        },
        -- 자동 완성 키 맵핑 설정
        mapping = cmp.mapping.preset.insert({
          ["<C-b>"] = cmp.mapping.scroll_docs(-4),
          ["<C-f>"] = cmp.mapping.scroll_docs(4),
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then
              luasnip.expand_or_jump()
            else
              fallback()
            end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
              cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then
              luasnip.jump(-1)
            else
              fallback()
            end
          end, { "i", "s" }),
        }),
      })
    end,
  },

  -- LuaSnip: 스니펫 엔진 플러그인
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = { "rafamadriz/friendly-snippets" },
  },

  -- Mason: LSP 서버, 린터, 포매터 설치 및 관리
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    config = function()
      require("mason").setup()
    end,
  },

  -- mason-lspconfig: mason과 nvim-lspconfig 연동
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local lspconfig = require("lspconfig")
      local mason_lspconfig = require("mason-lspconfig")

      -- LSP 서버가 성공적으로 활성화되면 실행될 함수입니다.
      local on_attach = function(client, bufnr)
        local keymap = vim.keymap.set
        local opts = { silent = true, buffer = bufnr }
        
        keymap("n", "gd", vim.lsp.buf.definition, opts)
        keymap("n", "gD", vim.lsp.buf.declaration, opts)
        keymap("n", "gr", vim.lsp.buf.references, opts)
        keymap("n", "gi", vim.lsp.buf.implementation, opts)
        keymap("n", "K", vim.lsp.buf.hover, opts)
        keymap("n", "<leader>rn", vim.lsp.buf.rename, opts)
        keymap("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        keymap("n", "<leader>f", function() vim.lsp.buf.format { async = true } end, opts)
      end

      -- mason으로 설치된 서버들을 자동으로 설정
      mason_lspconfig.setup({
        ensure_installed = {
          "lua_ls",     -- Lua
          "jdtls",      -- Java
          "clangd",     -- C++
          "pyright",    -- Python
          "cssls",      -- CSS
          "html",       -- HTML
          "jsonls",     -- JSON
          "ts_ls",   -- JavaScript & TypeScript
        },
        handlers = {
          function(server_name)
            lspconfig[server_name].setup({
              on_attach = on_attach,
            })
          end,
        },
      })
    end,
  },
  
  -- nvim-lspconfig: LSP 클라이언트 설정
  {
    "neovim/nvim-lspconfig",
  }
}
