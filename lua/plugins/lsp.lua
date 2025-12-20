-- ==========================================================================
-- LSP, FORMATTING & SYNTAX HIGHLIGHTING
-- ==========================================================================
-- lua/plugins/lsp.lua
-- This file handles:
-- 1. Treesitter (Syntax Highlighting)
-- 2. Mason (Tool/Server Installer)
-- 3. LSP Config (Language Server Protocol)
-- 4. Conform (Auto-formatting)

return {
    -- ==========================================================================
    -- 1. TREESITTER (Syntax Highlighting)
    -- ==========================================================================
    {
        "nvim-treesitter/nvim-treesitter",
        build           = ":TSUpdate",
        event           = { "BufReadPost", "BufNewFile" },

        opts = {
            ensure_installed = {
                "lua",
                "python",
                "bash",
            },
            sync_install    = false,
            auto_install    = true,

            -- Highlighting Configuration
            highlight = {
                enable      = true,
                -- Note: turning this on may slow down large files
                additional_vim_regex_highlighting = true,
            },

            -- Indentation
            indent = {
                enable      = true
            },
        },

        config = function(_, opts)
            require("nvim-treesitter").setup(opts)
        end,
    },

    -- ==========================================================================
    -- 2. MASON (Tool Installer)
    -- ==========================================================================
    {
        "williamboman/mason.nvim",
        cmd             = "Mason",
        dependencies    = {
            "williamboman/mason-lspconfig.nvim",        -- Bridge between Mason & LSPConfig
            "WhoIsSethDaniel/mason-tool-installer.nvim",-- Auto-installer for Linters/Formatters
        },

        config = function()
            local mason                 = require("mason")
            local mason_lspconfig       = require("mason-lspconfig")
            local mason_tool_installer  = require("mason-tool-installer")

            -- 1. Setup Mason UI
            -- ----------------------------------------------------------------------
            mason.setup({
                ui = {
                    icons = {
                        package_installed   = "✓",
                        package_pending     = "➜",
                        package_uninstalled = "✗",
                    },
                },
            })

            -- 2. Setup Tool Installer (Formatters & Linters)
            -- ----------------------------------------------------------------------
            mason_tool_installer.setup({
                ensure_installed = {
                    "prettier",         -- JS/TS/HTML/CSS Formatter
                    "stylua",           -- Lua Formatter
                    "black",            -- Python Formatter
                    "isort",            -- Python Import Sorter
                    "flake8",           -- Python Linter
                    "shellcheck",       -- Bash Linter
                    "shfmt",            -- Bash Formatter
                    "clang-format",     -- C/C++ Formatter
                    "eslint_d",         -- JS/TS Linter
                },
            })

            -- 3. Setup Mason-LSPConfig (Language Servers)
            -- ----------------------------------------------------------------------
            mason_lspconfig.setup({
                ensure_installed = {
                    "lua_ls",
                    "pyright",
                    -- Add other servers here (e.g., "tsserver", "clangd")
                },
                automatic_installation = true,
            })
        end,
    },

    -- ==========================================================================
    -- 3. LSP CONFIG (Language Server Setup)
    -- ==========================================================================
    {
        "neovim/nvim-lspconfig",
        event           = { "BufReadPre", "BufNewFile" },
        dependencies    = {
            "williamboman/mason.nvim",
            "williamboman/mason-lspconfig.nvim",
            "hrsh7th/cmp-nvim-lsp", -- Links LSP to Autocompletion
        },

        config = function()
        -- 1. Configure Global Capabilities
        local capabilities = require("cmp_nvim_lsp").default_capabilities()
        
        -- 2. Define and Enable Server Configurations
        -- Use vim.lsp.config() to set defaults for all servers
        vim.lsp.config("*", {
            capabilities = capabilities,
        })

        -- Enable your specific servers
        -- This automatically pulls defaults from nvim-lspconfig
        vim.lsp.enable({ "lua_ls", "pyright" })
    end,
    },

    -- ==========================================================================
    -- 4. CONFORM (Auto-Formatting)
    -- ==========================================================================
    {
        "stevearc/conform.nvim",
        event   = { "BufWritePre" },
        cmd     = { "ConformInfo" },
        
        opts = {
            -- Define formatters per language
            formatters_by_ft = {
                lua          = { "stylua"         },
                python       = { "isort", "black" },
                javascript   = { "prettier"       },
                typescript   = { "prettier"       },
                css          = { "prettier"       },
                html         = { "prettier"       },
                json         = { "prettier"       },
                yaml         = { "prettier"       },
                markdown     = { "prettier"       },
                bash         = { "shfmt"          },
            },

            -- Format on save settings
            format_on_save = {
                timeout_ms      = 500,
                lsp_fallback    = true, -- Use LSP formatting if no formatter defined above
            },
        },
    },
}
