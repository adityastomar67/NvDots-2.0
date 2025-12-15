-- ==========================================================================
-- CORE VIM OPTIONS
-- ==========================================================================
-- lua/config/options.lua
-- Options are automatically loaded before lazy.nvim startup.
-- This file controls the behavior of Neovim (UI, editing, indentation, etc.).

local opt                                       = vim.opt
local g                                         = vim.g

-- --------------------------------------------------------------------------
-- 1. Import User Environment
-- --------------------------------------------------------------------------
-- We use pcall to ensure it doesn't crash if the file is missing or broken.
-- This allows for machine-specific overrides without changing the main config.
local env_status, env                           = pcall(require, "config.user_env")
local env_config                                = env_status and env.config or {}

-- ==========================================================================
-- 2. GENERAL SETTINGS
-- ==========================================================================

-- Backup and Swap
opt.backup                                      = false         -- No backup file
opt.writebackup                                 = false         -- No backup during write
opt.swapfile                                    = false         -- No swap file
opt.undofile                                    = true          -- Enable persistent undo (undo history persists after closing)

-- File and Clipboard
opt.fileencoding                                = "utf-8"       -- File encoding
opt.clipboard                                   = "unnamedplus" -- Sync with system clipboard (Options: "unnamed", "unnamedplus")
opt.mouse                                       = "a"           -- Enable mouse support (Options: "a" (all), "n", "v", "i")

-- Search Settings
opt.ignorecase                                  = true          -- Ignore case in search
opt.smartcase                                   = true          -- Smart case (case-sensitive if uppercase used)
opt.icm                                         = "split"       -- Live preview for substitute (Options: "nosplit", "split")

-- UI / Display
opt.conceallevel                                = 2             -- 0: Show all, 1: Conceal chars, 2: Conceal + Collapse, 3: Hide fully
opt.showmode                                    = false         -- Hide "-- INSERT --" (handled by statusline/lualine)
opt.termguicolors                               = true          -- True color support
opt.pumheight                                   = 10            -- Maximum number of items in popup menu
opt.scrolloff                                   = 8             -- Keep 8 lines above/below cursor when scrolling
opt.sidescrolloff                               = 8             -- Keep 8 columns left/right of cursor
opt.splitbelow                                  = false         -- Horizontal splits go below? (User preference: No)
opt.splitright                                  = true          -- Vertical splits go to the right
opt.wrap                                        = true          -- Wrap long lines (Options: true, false)
opt.cursorline                                  = true          -- Highlight the current line
opt.cursorlineopt                               = "number"      -- Highlight options (Options: "line", "screenline", "number", "both")
opt.winblend                                    = 0             -- Window transparency (0 = opaque, 100 = transparent)
opt.fillchars                                   = {eob = " "}   -- Character to show at end of buffer (Hide "~")

-- Statusline / Command Line
-- Logic: Use global statusline (3) if enabled in user_env, otherwise hide it (0)
opt.laststatus                                  = env_config.enable_statusline and 3 or 0
opt.cmdheight                                   = 0             -- Hide command line for cleaner UI (Options: 0, 1, 2)

-- Indentation
opt.expandtab                                   = true          -- Use spaces instead of tabs
opt.shiftwidth                                  = 4             -- Size of an indent
opt.tabstop                                     = 4             -- Number of spaces tabs count for
opt.smartindent                                 = true          -- Insert indents automatically

-- Folding
opt.foldmethod                                  = "indent"      -- Folding method (Options: "manual", "indent", "expr", "marker")
opt.foldlevel                                   = 99            -- Open all folds by default
opt.foldenable                                  = false         -- Disable folding on startup
opt.foldnestmax                                 = 10            -- Maximum nesting of folds

-- Line Numbers and Columns
opt.number                                      = false         -- Disable line numbers (Zen-like default)
opt.relativenumber                              = false         -- Disable relative numbers
opt.numberwidth                                 = 2             -- Minimal number column width
opt.signcolumn                                  = "yes"         -- Always show sign column (Options: "auto", "no", "yes")

-- Performance / Misc
opt.timeoutlen                                  = 1000          -- Time (ms) to wait for a mapped sequence to complete
opt.updatetime                                  = 300           -- Debounce time for completion (default 4000)
opt.completeopt                                 = {             -- Options for Insert mode completion
    "menuone",                                                  -- Show popup even if there is only one match
    "noselect"                                                  -- Do not select a match in the menu automatically
}

-- ==========================================================================
-- 3. FORMAT OPTIONS
-- ==========================================================================
-- These control how text is auto-formatted (e.g., wrapping comments).

-- Remove unwanted behaviors
opt.formatoptions:remove("a")                                   -- No auto-formatting
opt.formatoptions:remove("t")                                   -- No auto-wrap code
opt.formatoptions:remove("o")                                   -- No comment continuation on 'o' or 'O'
opt.formatoptions:remove("2")                                   -- No indent using 2nd line of paragraph

-- Add desired behaviors
opt.formatoptions:append("c")                                   -- Auto-wrap comments using textwidth
opt.formatoptions:append("q")                                   -- Allow formatting comments with 'gq'
opt.formatoptions:append("r")                                   -- Continue comment leader on hitting Enter
opt.formatoptions:append("n")                                   -- Recognize numbered lists
opt.formatoptions:append("j")                                   -- Remove comment leader when joining lines

opt.shortmess:append("c")                                       -- Hide completion messages (e.g., "-- match 1 of 2")
opt.whichwrap:append("<>[]hl")                                  -- Allow h/l keys to wrap to previous/next line

-- Cursor Styles
-- Defines the shape and blinking of the cursor in different modes.
opt.guicursor                                   = {
    "n-v:block",                                                -- Normal/Visual: Block
    "i-c-ci-ve:ver25",                                          -- Insert/Command: Vertical bar
    "r-cr:hor20",                                               -- Replace: Horizontal underline
    "o:hor50",                                                  -- Operator-pending: Horizontal underline
    "i:blinkwait700-blinkoff400-blinkon250-Cursor/lCursor",     -- Blink settings for Insert
    "sm:block-blinkwait175-blinkoff150-blinkon175"              -- Showmatch: Fast blink
}

-- ==========================================================================
-- 4. GLOBAL VARIABLES (Providers & Plugins)
-- ==========================================================================

-- Python Provider
-- We use the path from user_env if provided, otherwise disable it for startup speed.
if env_config.python3_host_prog then
    g.python3_host_prog                         = env_config.python3_host_prog
    g.loaded_python3_provider                   = nil           -- Let Neovim load the provider
else
    g.loaded_python3_provider                   = 0             -- Disable if not specified
end

-- Disable other language providers (Startuptime optimization)
g.loaded_python_provider                        = 0             -- Disable Python 2 (Deprecated)
g.loaded_ruby_provider                          = 0             -- Disable Ruby
g.loaded_node_provider                          = 0             -- Disable Node
g.loaded_perl_provider                          = 0             -- Disable Perl

-- Matchparen (Highlight matching brackets)
g.matchparen_timeout                            = 20            -- Timeout in ms for highlight calculation
g.matchparen_insert_timeout                     = 20            -- Timeout in ms during insert mode

-- Editorconfig
g.EditorConfig_core_mode                        = "external_command"

-- Markdown Fenced Languages
-- Enables syntax highlighting for code blocks inside Markdown files
g.markdown_fenced_languages                     = {
    "html",
    "javascript",
    "typescript",
    "css",
    "scss",
    "lua",
    "vim",
    "bash",
    "python",
    "json"
}

-- ==========================================================================
-- 5. DISABLE BUILT-IN PLUGINS
-- ==========================================================================
-- Disabling unused built-in plugins improves startup time.

local disabled_built_ins                        = {
    "2html_plugin",
    "getscript",
    "getscriptPlugin",
    "gzip",
    "logipat",
    "matchit",
    "tar",
    "tarPlugin",
    "rrhelper",
    "spellfile_plugin",
    "vimball",
    "vimballPlugin",
    "zip",
    "zipPlugin",
    "tutor",
    "rplugin",
    "syntax",
    "synmenu",
    "optwin",
    "compiler",
    "bugreport",
    "ftplugin"
    -- "netrw",         -- Keep netrw disabled if you use NvimTree
    -- "netrwPlugin",
    -- "netrwSettings",
}

for _, plugin in pairs(disabled_built_ins) do
    g["loaded_" .. plugin]                      = 1
end

-- ==========================================================================
-- 6. FINAL ADJUSTMENTS
-- ==========================================================================

-- Set a minimal statusline text for the fallback mode
vim.cmd([[let &statusline='%#Normal# ']])
