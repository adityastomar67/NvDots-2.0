-- ==========================================================================
-- ZEN MODE UTILITY
-- ==========================================================================
-- lua/util/zen.lua
-- A minimal "Zen Mode" script that toggles distraction-free editing.
-- DEPENDENCY: Requires 'junegunn/limelight.vim' for the dimming effect.

local Zen                                       = {}

-- Initialize state based on user config
-- We use pcall to safely check the user environment; default to false if missing.
local ok, env                                   = pcall(require, "config.user_env")
local zen_active                                = ok and env.config.is_zen or false

-- ==========================================================================
-- 1. TOGGLE FUNCTION
-- ==========================================================================

Zen.toggle = function()
    -- GUARD CLAUSE: Check if dependencies are installed
    -- vim.fn.exists(":Limelight") returns 2 if the command exists (full match)
    if vim.fn.exists(":Limelight") == 0 then
        vim.notify("Zen Mode: 'junegunn/limelight.vim' is not installed or loaded.", vim.log.levels.ERROR)
        return
    end
    
    -- Flip the state
    zen_active                                  = not zen_active

    if zen_active then
        -- ------------------------------------------------------------------
        -- ENABLE ZEN MODE (Distraction Free)
        -- ------------------------------------------------------------------
        vim.cmd("Limelight")                    -- Dim surrounding paragraphs (Focus)
        
        vim.opt.number                          = false         -- Hide line numbers
        vim.opt.relativenumber                  = false         -- Hide relative numbers
        vim.opt.signcolumn                      = "no"          -- Hide git signs/diagnostics
        vim.opt.laststatus                      = 0             -- Hide statusline completely
        vim.opt.cmdheight                       = 0             -- Hide command line
        
        vim.notify("Zen Mode: ON", vim.log.levels.INFO)
    else
        -- ------------------------------------------------------------------
        -- DISABLE ZEN MODE (Restore Defaults)
        -- ------------------------------------------------------------------
        vim.cmd("Limelight!")                   -- Turn off dimming
        
        vim.opt.number                          = true          -- Show line numbers
        vim.opt.relativenumber                  = true          -- Show relative numbers
        vim.opt.signcolumn                      = "yes"         -- Show sign column
        vim.opt.laststatus                      = 3             -- Restore global statusline
        vim.opt.cmdheight                       = 1             -- Restore command line
        
        vim.notify("Zen Mode: OFF", vim.log.levels.INFO)
    end
end

-- ==========================================================================
-- 2. KEYMAPPING
-- ==========================================================================

-- Keymap: <leader>z to toggle
vim.keymap.set("n", "<leader>z", Zen.toggle, {
    noremap                                     = true,
    silent                                      = true,
    desc                                        = "Toggle Zen Mode"
})

return Zen
