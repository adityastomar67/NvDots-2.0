-- ==========================================================================
-- LAZY.NVIM BOOTSTRAP & CONFIGURATION
-- ==========================================================================
-- lua/config/lazy.lua
-- This file handles the installation and setup of the 'lazy.nvim' plugin manager.

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

-- --------------------------------------------------------------------------
-- 1. Bootstrap Lazy.nvim
-- --------------------------------------------------------------------------
-- Bootstrap: Clone lazy.nvim if not present
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local out =
        vim.fn.system(
        {
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable", -- latest stable release (Options: "stable", "main")
            lazypath
        }
    )

    -- Safety check for git clone errors
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo(
            {
                {"Failed to clone lazy.nvim:\n", "ErrorMsg"},
                {out, "WarningMsg"},
                {"\nPress any key to exit..."}
            },
            true,
            {}
        )
        vim.fn.getchar()
        os.exit(1)
    end
end
vim.opt.rtp:prepend(lazypath)

-- --------------------------------------------------------------------------
-- 2. Setup Lazy.nvim
-- --------------------------------------------------------------------------
require("lazy").setup(
    {
        spec = {
            {import = "plugins"}    -- This automatically imports any file inside lua/plugins/*.lua
        },
        -- Minimal UI configuration for Lazy window
        ui = {
            border  = "rounded"     -- Options: "none", "single", "double", "rounded", "solid", "shadow"
        },
        -- performance updates
        checker = {
            enabled = true,         -- Check updates silently (Options: true, false)
            notify  = false         -- Disable notification when checking (Options: true, false)
        },
        change_detection = {
            notify  = false         -- Don't spam notifications on config change (Options: true, false)
        }
    }
)

-- --------------------------------------------------------------------------
-- 3. Load Core Configurations
-- --------------------------------------------------------------------------
-- Load core config files after plugins are setup
require("config.keymaps")
require("config.autocmds")
