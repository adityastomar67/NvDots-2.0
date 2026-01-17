-- ==========================================================================
-- NEOVIM INITIALIZATION
-- ==========================================================================
-- init.lua
-- This is the main entry point for Neovim. It loads user settings, sets
-- global leader keys, and then bootstraps the lazy.nvim package manager.

-- --------------------------------------------------------------------------
-- 1. Load User Environment
-- --------------------------------------------------------------------------
-- Import environment-specific configurations (paths, toggles, keys).
local env = require("config.user_env")

-- --------------------------------------------------------------------------
-- 2. Set Global Leader Keys
-- --------------------------------------------------------------------------
-- It is crucial to set these BEFORE loading lazy.nvim or any plugins,
-- as plugins often check the leader key during their setup.

vim.g.mapleader = env.config.mapleader -- Primary leader key (e.g., Space)
vim.g.maplocalleader = env.config.maplocalleader -- Local leader key (e.g., Backslash)

-- --------------------------------------------------------------------------
-- 3. Bootstrap Plugin Manager
-- --------------------------------------------------------------------------
-- Load 'lua/config/lazy.lua' which installs lazy.nvim and loads plugins.
require("config.lazy")

-- FIX: all the multinode snippets not working
-- TODO: Create a dynamic snippet with multiple options to choose from in a single snippet
