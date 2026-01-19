return {
  -- nvim-lspconfig: 서버별 config 데이터 제공(자체는 deprecated 아님) :contentReference[oaicite:5]{index=5}
  { "neovim/nvim-lspconfig" },

  -- Mason
  {
    "mason-org/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    dependencies = { "mason-org/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "gopls", "kotlin_language_server" },
        automatic_installation = true,
      })
    end,
  },

  -- Auto-install linters & formatters
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    config = function()
      require("mason-tool-installer").setup({
        ensure_installed = {
          "ruff", -- Python linter/formatter
          "stylua", -- Lua formatter
          "ktlint", -- Kotlin linter/formatter
          "golangci-lint", -- Go linter
        },
      })
    end,
  },

  -- Completion
  {
    "hrsh7th/nvim-cmp",
    event = "InsertEnter",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        mapping = cmp.mapping.preset.insert({
          ["<C-Space>"] = cmp.mapping.complete(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
          ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_next_item()
            elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
            else fallback() end
          end, { "i", "s" }),
          ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then cmp.select_prev_item()
            elseif luasnip.jumpable(-1) then luasnip.jump(-1)
            else fallback() end
          end, { "i", "s" }),
        }),
        sources = cmp.config.sources({
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
        }),
      })
    end,
  },

  -- LSP wiring (vim.lsp.config + vim.lsp.enable)
  {
    "neovim/nvim-lspconfig",
    dependencies = { "hrsh7th/cmp-nvim-lsp" },
    config = function()
      local capabilities = require("cmp_nvim_lsp").default_capabilities()

      local on_attach = function(_, bufnr)
        local map = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
        end
        map("n", "gd", vim.lsp.buf.definition, "Go to definition")
        map("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        map("n", "gr", vim.lsp.buf.references, "Find references")
        map("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        map("n", "K", vim.lsp.buf.hover, "Hover")
        map("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        map("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        map("n", "<leader>ds", vim.diagnostic.open_float, "Line diagnostics")
        map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
      end

      vim.diagnostic.config({
        virtual_text = true,
        severity_sort = true,
        float = { border = "rounded", source = "if_many" },
      })

      -- 0.11+ 권장: vim.lsp.config / vim.lsp.enable :contentReference[oaicite:6]{index=6}
      vim.lsp.config("pyright", {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
          python = {
            analysis = {
              autoSearchPaths = true,
              useLibraryCodeForTypes = true,
              diagnosticMode = "workspace",
            },
          },
        },
        on_init = function(client)
          local root_dir = client.workspace_folders and client.workspace_folders[1].name or vim.loop.cwd()
          local venv_python = nil

          -- 가상환경 내의 python 실행 파일 위치 후보군
          local potential_paths = {
            root_dir .. "/.uv/bin/python",
            root_dir .. "/.venv/bin/python",
            root_dir .. "/venv/bin/python",
          }

          for _, path in ipairs(potential_paths) do
            if vim.loop.fs_stat(path) then
              venv_python = path
              break
            end
          end

          if venv_python then
            client.config.settings.python.pythonPath = venv_python
            client.notify("workspace/didChangeConfiguration", { settings = client.config.settings })
          end
          return true
        end,
      })
      vim.lsp.config("gopls",   { capabilities = capabilities, on_attach = on_attach })
      vim.lsp.config("kotlin_language_server", { capabilities = capabilities, on_attach = on_attach })

      vim.lsp.enable("pyright")
      vim.lsp.enable("gopls")
      vim.lsp.enable("kotlin_language_server")
    end,
  },
}