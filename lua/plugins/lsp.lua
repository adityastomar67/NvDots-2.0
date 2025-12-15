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
                "markdown",
                "markdown_inline",
                "bash",
                "vim",
                "vimdoc"
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
            local lspconfig     = require("lspconfig")
            local mason_lsp     = require("mason-lspconfig")
            local capabilities  = require("cmp_nvim_lsp").default_capabilities()

            -- 1. Diagnostic UI Configuration
            -- ----------------------------------------------------------------------
            vim.diagnostic.config({
                virtual_text        = true,         -- Show text inline
                signs               = true,         -- Show signs in gutter
                underline           = true,         -- Underline errors
                update_in_insert    = false,        -- Don't update while typing
                severity_sort       = true,         -- Sort by severity

                float = {
                    focusable       = false,
                    style           = "minimal",
                    border          = "rounded",
                    source          = "always",
                    header          = "",
                    prefix          = "",
                },
            })

            -- 2. Setup Handlers (CRITICAL)
            -- ----------------------------------------------------------------------
            -- This function automatically sets up every server installed via Mason
            -- mason_lsp.setup_handlers({
            --     function(server_name)
            --         lspconfig[server_name].setup({
            --             capabilities = capabilities,
            --             -- Add 'on_attach' here if you want legacy keymaps
            --         })
            --     end,
            -- })

            -- 3. LspAttach Autocommand
            -- ----------------------------------------------------------------------
            -- Use this to set keymaps only when an LSP attaches to a buffer
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("UserLspConfig", {}),
                callback = function(ev)
                    -- Example: Enable omnifunc
                    -- vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
                    
                    -- NOTE: We are using Snacks.picker for LSP navigation (gd, gr, etc.)
                    -- defined in keymaps.lua, so we don't need to duplicate them here.
                    -- You can add buffer-local mappings here like 'K' for hover if needed.
                end,
            })
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
