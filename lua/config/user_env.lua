-- ==========================================================================
-- USER ENVIRONMENT & GLOBAL CONFIGURATION
-- ==========================================================================
-- lua/config/user_env.lua
-- This module acts as a "source of truth" for user-specific settings.
-- It exports a configuration table used by other parts of the config.

local env = {}

env.config = {
    -- ----------------------------------------------------------------------
    -- Core Setup
    -- ----------------------------------------------------------------------
    mapleader                           = " ",          -- Primary leader key (Space is recommended)
    maplocalleader                      = "\\",         -- Local leader key (often Backslash)

    -- ----------------------------------------------------------------------
    -- UI Preferences
    -- ----------------------------------------------------------------------
    theme                               = "kanagawa",   -- Active color scheme
    transparent                         = true,         -- Enable transparent background
    is_zen                              = false,        -- For all the minimalists       

    -- ----------------------------------------------------------------------
    -- Feature Toggles
    -- ----------------------------------------------------------------------
    enable_lsp                          = true,         -- Enable Language Server Protocol
    enable_treesitter                   = true,         -- Enable Treesitter highlighting
    enable_statusline                   = false,        -- Enable Statusline (lualine/airline)
    enable_copilot                      = false,        -- Enable GitHub Copilot

    -- ----------------------------------------------------------------------
    -- Path Settings
    -- ----------------------------------------------------------------------
    -- Path to specific Python 3 executable (useful for virtualenvs)
    -- Set to nil to use the system default or rely on $PATH.
    python3_host_prog                   = nil,

    -- ----------------------------------------------------------------------
    -- Toggler Configuration
    -- ----------------------------------------------------------------------
    -- Defines pairs of words that can be cycled (e.g., True <-> False).
    toggles = {                                               --examples
        -- Global Toggles: Work in any file type
        globals = {
            ["foo"]                     = "bar",
            ["enable"]                  = "disable",
            ["valid"]                   = "invalid"
        },

        -- Filetype Specific Toggles: Work only in matching file types
        filetypes = {                                    
            python = {
                ["True"]                = "False",
                ["import"]              = "from"
            },
            lua = {
                ["local"]               = "global",
                ["nil"]                 = "non-nil"
            },
            javascript = {
                ["const"]               = "let",
                ["true"]                = "false"
            }
        }
    }
}

return env
