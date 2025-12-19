-- ==========================================================================
-- FILE EXPLORER & UTILITIES
-- ==========================================================================
-- lua/plugins/explorer.lua
-- Configures NvimTree for file management and Limelight for focus mode.

return {
    -- ==========================================================================
    -- 1. FILE EXPLORER (NvimTree)
    -- ==========================================================================
    {
        "nvim-tree/nvim-tree.lua",
        version         = "*",
        lazy            = true,
        dependencies    = { "nvim-tree/nvim-web-devicons" },
        keys            = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" },
        },
        
        config = function()
            local nvim_tree = require("nvim-tree")
            
            -- ----------------------------------------------------------------------
            -- Setup Options
            -- ----------------------------------------------------------------------
            nvim_tree.setup({
                -- on_attach               = on_attach,
                on_attach               = require("config.keymaps").nvim_tree(),
                disable_netrw           = true,
                hijack_netrw            = true,
                sync_root_with_cwd      = true,
                auto_reload_on_write    = true,
                
                -- Update behavior
                update_focused_file = {
                    enable              = true,
                    update_root         = true 
                },
                
                -- Git integration
                git = {
                    enable              = true,
                    ignore              = true,
                    timeout             = 500 
                },
                
                -- Filters
                filters = {
                    custom              = { ".git" } 
                },
                
                -- UI / View
                view = {
                    width               = 30,
                    side                = "left" 
                },

                -- Renderer & Icons
                renderer = {
                    highlight_opened_files = "name",
                    indent_markers         = { enable = true },
                    icons = {
                        glyphs = {
                            default = "",
                            symlink = "",
                            git = {
                                unstaged = "", staged    = "S", unmerged  = "",
                                renamed  = "➜", deleted   = "", untracked = "U",
                                ignored  = "◌"
                            },
                            folder = {
                                default    = "", open      = "", empty    = "",
                                empty_open = "", symlink   = ""
                            },
                        },
                    },
                },
            })
        end,
    },

    -- ==========================================================================
    -- 2. FOCUS UTILITY (Limelight)
    -- ==========================================================================
    -- Used by Zen Mode to dim surrounding code.
    {
        "junegunn/limelight.vim",
        cmd  = "Limelight",
        init = function()
            -- Limelight Configuration
            vim.g.limelight_conceal_ctermfg = "gray"
            vim.g.limelight_conceal_guifg   = "#777777"
            vim.g.limelight_default_coefficient = 0.7
            
            -- Optional: Link it to your Zen Mode toggle
            vim.g.limelight_paragraph_span = 1
        end
    },
}
