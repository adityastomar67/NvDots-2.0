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
        lazy            = false,
        dependencies    = { "nvim-tree/nvim-web-devicons" },
        keys            = {
            { "<leader>e", "<cmd>NvimTreeToggle<cr>", desc = "Toggle Explorer" },
        },
        
        config = function()
            local nvim_tree = require("nvim-tree")
            local api       = require("nvim-tree.api")

            -- ----------------------------------------------------------------------
            -- Custom Attach Function (Keymaps)
            -- ----------------------------------------------------------------------
            local function on_attach(bufnr)
                local function opts(desc)
                    return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
                end

                -- Navigation
                vim.keymap.set("n", "l"         , api.node.open.edit            , opts("Open"))
                vim.keymap.set("n", "<CR>"      , api.node.open.edit            , opts("Open"))
                vim.keymap.set("n", "o"         , api.node.open.edit            , opts("Open"))
                vim.keymap.set("n", "h"         , api.node.navigate.parent_close, opts("Close Directory"))
                vim.keymap.set("n", "<C-v>"     , api.node.open.vertical        , opts("Open: Vertical Split"))
                vim.keymap.set("n", "<C-x>"     , api.node.open.horizontal      , opts("Open: Horizontal Split"))

                -- File Manipulation
                vim.keymap.set("n", "a"         , api.fs.create                 , opts("Create"))
                vim.keymap.set("n", "d"         , api.fs.remove                 , opts("Delete"))
                vim.keymap.set("n", "r"         , api.fs.rename                 , opts("Rename"))
                vim.keymap.set("n", "y"         , api.fs.copy.filename          , opts("Copy Name"))
                vim.keymap.set("n", "Y"         , api.fs.copy.relative_path     , opts("Copy Relative Path"))
                vim.keymap.set("n", "gy"        , api.fs.copy.absolute_path     , opts("Copy Absolute Path"))

                -- Tree Management
                vim.keymap.set("n", "q"         , api.tree.close                , opts("Close"))
                vim.keymap.set("n", "W"         , api.tree.collapse_all         , opts("Collapse"))
                vim.keymap.set("n", "S"         , api.tree.search_node          , opts("Search"))
                vim.keymap.set("n", "<C-k>"     , api.node.show_info_popup      , opts("Info"))
                vim.keymap.set("n", "?"         , api.tree.toggle_help          , opts("Help"))

                -- Resizing
                vim.keymap.set("n", ">"         , function() vim.cmd("NvimTreeResize +10") end, opts("Expand Width"))
                vim.keymap.set("n", "<"         , function() vim.cmd("NvimTreeResize -10") end, opts("Collapse Width"))
            end

            -- ----------------------------------------------------------------------
            -- Setup Options
            -- ----------------------------------------------------------------------
            nvim_tree.setup({
                on_attach               = on_attach,
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
            vim.g.limelight_conceal_ctermfg = 240
            vim.g.limelight_conceal_guifg   = "#777777"
        end
    },
}
