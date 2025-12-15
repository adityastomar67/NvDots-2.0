-- ==========================================================================
-- THEME CONFIGURATION
-- ==========================================================================
-- lua/plugins/theme.lua
-- This file configures the active colorscheme (Kanagawa) and UI elements
-- like diagnostic signs and transparency overrides.

-- Import user environment settings
local env = require("config.user_env").config

return {
    -- ==========================================================================
    -- 1. KANAGAWA THEME
    -- ==========================================================================
    {
        "rebelot/kanagawa.nvim",
        lazy        = false,    -- Load immediately during startup
        priority    = 1000,     -- Load before other UI plugins

        config = function()
            -- ----------------------------------------------------------------------
            -- 1. UI Setup: Diagnostic Signs
            -- ----------------------------------------------------------------------
            -- Define custom icons for LSP diagnostics in the sign column.
            local signs = {
                Error = "",
                Warn  = "",
                Hint  = "󰠠",
                Info  = ""
            }

            for type, icon in pairs(signs) do
                local hl = "DiagnosticSign" .. type
                vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = "" })
            end

            -- ----------------------------------------------------------------------
            -- 2. Theme Configuration
            -- ----------------------------------------------------------------------
            require("kanagawa").setup({
                compile         = true,                 -- Enable compiling the colorscheme
                undercurl       = true,                 -- Enable undercurls
                commentStyle    = { italic = true },
                keywordStyle    = { italic = true },
                statementStyle  = { bold   = true },
                transparent     = env.transparent,      -- Use setting from user_env.lua

                -- ------------------------------------------------------------------
                -- Overrides
                -- ------------------------------------------------------------------
                -- Customizes specific highlight groups.
                -- Note: We use 'colors.theme.ui' to access palette colors.
                overrides = function(colors)
                    local theme = colors.theme
                    return {
                        -- 1. Editor UI (Transparency & Splits)
                        LineNr              = { bg = "NONE" },
                        CursorLineNr        = { bg = "NONE" },
                        SignColumn          = { bg = "NONE" },
                        VertSplit           = { fg = theme.ui.bg_m3 , bg = "NONE" },
                        WinSeparator        = { fg = theme.ui.bg_m3 , bg = "NONE" },

                        -- 2. LSP Diagnostic Signs (Remove Backgrounds)
                        DiagnosticSignError = { bg = "NONE" },
                        DiagnosticSignWarn  = { bg = "NONE" },
                        DiagnosticSignInfo  = { bg = "NONE" },
                        DiagnosticSignHint  = { bg = "NONE" },

                        -- 3. GitSigns (Remove Backgrounds)
                        GitSignsAdd         = { bg = "NONE" },
                        GitSignsChange      = { bg = "NONE" },
                        GitSignsDelete      = { bg = "NONE" },

                        -- 4. Floating Windows & Borders
                        NormalFloat         = { bg = "NONE" },
                        FloatBorder         = { bg = "NONE" },

                        -- 5. Custom / Misc
                        SaveAsRoot          = { fg = theme.ui.fg_dim, bg = "NONE" },
                    }
                end,
            })

            -- ----------------------------------------------------------------------
            -- 3. Load Colorscheme
            -- ----------------------------------------------------------------------
            -- Applies the theme defined in user_env (defaults to "kanagawa")
            vim.cmd.colorscheme(env.theme)
        end,
    },
}
