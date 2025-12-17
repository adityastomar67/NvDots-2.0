-- ==========================================================================
-- GIT & TODO CONFIGURATION
-- ==========================================================================
-- lua/plugins/git_todo.lua
-- This file configures 'todo-comments.nvim' for highlighting annotations
-- and 'gitsigns.nvim' for git integration in the gutter.

return {
    -- {
    --     "kdheepak/lazygit.nvim",
    --     cmd = "LazyGit",
    --     keys = { { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" } },
    --  },
    -- ==========================================================================
    -- 1. TODO COMMENTS
    -- ==========================================================================
    {
        "folke/todo-comments.nvim",
        dependencies    = { "nvim-lua/plenary.nvim" },
        event           = { "BufReadPost", "BufNewFile" },

        opts = {
            -- ----------------------------------------------------------------------
            -- General Settings
            -- ----------------------------------------------------------------------
            signs           = true,         -- Show icons in the sign column
            sign_priority   = 8,            -- Sign priority
            merge_keywords  = true,         -- Merge with default keywords

            -- ----------------------------------------------------------------------
            -- Keywords
            -- ----------------------------------------------------------------------
            keywords = {
                FIX   = { icon = " ", color = "#C34043", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
                TODO  = { icon = "✖ ", color = "info"    },
                DONE  = { icon = " ", color = "done"    },
                HACK  = { icon = " ", color = "warning" },
                WARN  = { icon = " ", color = "error"    , alt = { "WARNING", "XXX" } },
                PERF  = { icon = " ", color = "info"     , alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
                NOTE  = { icon = " ", color = "hint"     , alt = { "INFO" } },
            },

            -- ----------------------------------------------------------------------
            -- Highlighting
            -- ----------------------------------------------------------------------
            highlight = {
                before        = "fg",       -- Options: "fg", "bg", "wide", or empty
                keyword       = "wide",     -- Options: "fg", "bg", "wide", or empty
                after         = "fg",       -- Options: "fg", "bg", "wide", or empty
                pattern       = [[.*<(KEYWORDS)\s*:]],
                comments_only = true,       -- Match only inside comments
                max_line_len  = 400,        -- Ignore lines longer than this
                exclude       = {},         -- List of filetypes to exclude
            },

            -- ----------------------------------------------------------------------
            -- Colors
            -- ----------------------------------------------------------------------
            colors = {
                error   = { "DiagnosticError"   , "ErrorMsg"    , "#DC2626" },
                warning = { "DiagnosticWarning" , "WarningMsg"  , "#FBBF24" },
                info    = { "DiagnosticInfo"    , "#7FB4CA"     },
                done    = { "DiagnosticDone"    , "#00A600"     },
                hint    = { "DiagnosticHint"    , "#10B981"     },
                default = { "Identifier"        , "#C34043"     },
            },

            -- ----------------------------------------------------------------------
            -- Search (Ripgrep)
            -- ----------------------------------------------------------------------
            search = {
                command = "rg",
                args    = {
                    "--color=never",
                    "--no-heading",
                    "--with-filename",
                    "--line-number",
                    "--column"
                },
                pattern = [[\b(KEYWORDS)\b\s*:]],
            },
        },
    },

    -- ==========================================================================
    -- 2. GITSIGNS
    -- ==========================================================================
    {
        "lewis6991/gitsigns.nvim",
        event = { "BufReadPre", "BufNewFile" },
        opts = {
            -- ----------------------------------------------------------------------
            -- Signs Configuration
            -- ----------------------------------------------------------------------
            -- Geometric Theme with linked Highlight Groups
            signs = {
                add          = { hl = "GitSignsAdd"   , text = "✚", numhl = "GitSignsAddNr"    , linehl = "GitSignsAddLn"    },
                change       = { hl = "GitSignsChange", text = "", numhl = "GitSignsChangeNr" , linehl = "GitSignsChangeLn" },
                delete       = { hl = "GitSignsDelete", text = "✖", numhl = "GitSignsDeleteNr" , linehl = "GitSignsDeleteLn" },
                topdelete    = { hl = "GitSignsDelete", text = "‾", numhl = "GitSignsDeleteNr" , linehl = "GitSignsDeleteLn" },
                changedelete = { hl = "GitSignsChange", text = "~", numhl = "GitSignsChangeNr" , linehl = "GitSignsChangeLn" },
                untracked    = { hl = "GitSignsAdd"   , text = "┆", numhl = "GitSignsAddNr"    , linehl = "GitSignsAddLn"    },
            },

            -- ----------------------------------------------------------------------
            -- General Settings
            -- ----------------------------------------------------------------------
            signcolumn          = true,     -- Toggle with :Gitsigns toggle_signs
            numhl               = true,     -- Toggle with :Gitsigns toggle_numhl
            linehl              = false,    -- Toggle with :Gitsigns toggle_linehl
            word_diff           = false,    -- Toggle with :Gitsigns toggle_word_diff
            current_line_blame  = false,    -- Toggle with :Gitsigns toggle_current_line_blame
            sign_priority       = 6,
            attach_to_untracked = true,

            -- ----------------------------------------------------------------------
            -- Watch & Debounce
            -- ----------------------------------------------------------------------
            watch_gitdir = {
                interval        = 1000,
                follow_files    = true
            },
            update_debounce     = 100,

            -- ----------------------------------------------------------------------
            -- Preview Options
            -- ----------------------------------------------------------------------
            preview_config = {
                border          = "single",
                style           = "minimal",
                relative        = "cursor",
                row             = 0,
                col             = 1
            },

            -- ----------------------------------------------------------------------
            -- Custom Highlights & Keymaps
            -- ----------------------------------------------------------------------
            on_attach = function(bufnr)
                -- Force vibrant colors (adjust Hex codes if you prefer different shades)
                vim.api.nvim_set_hl(0, "GitSignsAdd"    , { fg = "#98be65", bold = true }) -- Vibrant Green
                vim.api.nvim_set_hl(0, "GitSignsChange" , { fg = "#ecbe7b", bold = true }) -- Vibrant Orange/Yellow
                vim.api.nvim_set_hl(0, "GitSignsDelete" , { fg = "#ff6c6b", bold = true }) -- Vibrant Red

                -- Keymap: 'gs' to preview the hunk at cursor
                local gs = package.loaded.gitsigns
                vim.keymap.set("n", "gs", gs.preview_hunk, { buffer = bufnr, desc = "Preview Git Hunk" })
            end,
        },
    },
    -- ==========================================================================
    -- 4. UTILITIES (Cheat.sh)
    -- ==========================================================================
    -- {
    --     "RishabhRD/nvim-cheat.sh",
    --     dependencies    = "RishabhRD/popfix",
    --     cmd             = { "Cheat", "CheatWithoutComments" },
    -- },

    -- ==========================================================================
    -- 5. SNACKS.NVIM
    -- ==========================================================================
    -- A collection of small utilities (Picker, BigFile, etc.)
    {
        "folke/snacks.nvim",
        priority        = 1000,
        lazy            = false,
        ---@type snacks.Config
        opts = {
            -- Picker: Acts as a Telescope replacement
            picker      = { enabled = true },
            
            -- Helpers: Run in background to improve performance/experience
            bigfile     = { enabled = true },
            quickfile   = { enabled = true },
        },
    },
}
