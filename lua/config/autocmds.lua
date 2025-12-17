-- ==========================================================================
-- AUTOCOMMANDS & USER COMMANDS
-- ==========================================================================
-- lua/config/autocmds.lua
-- This file defines custom user commands and automatic behaviors (events).
-- It relies on helper functions defined in 'core.utils'.

local api                = vim.api
local utils              = require("util.utils")

-- Load User Environment
local env_status, env    = pcall(require, "config.user_env")
local env_config         = env_status and env.config or {}

-- ==========================================================================
-- 1. USER COMMANDS
-- ==========================================================================

-- Text Manipulation
-- --------------------------------------------------------------------------
api.nvim_create_user_command("Cls",
    function()
        utils.preserve('%s/\\s\\+$//ge')
    end,
    { desc = "Remove trailing whitespace" }
)

-- api.nvim_create_user_command("Dos2Unix",
--     utils.dos_to_unix,
--     { desc = "Convert DOS line endings to Unix (CRLF -> LF)" }
-- )

api.nvim_create_user_command("Squeeze",
    utils.squeeze_blank_lines,
    { desc = "Remove consecutive blank lines" }
)

api.nvim_create_user_command("Reindent",
    utils.reindent,
    { desc = "Re-indent the entire file" }
)

-- Buffer Management
-- --------------------------------------------------------------------------
-- api.nvim_create_user_command("BufOnly",
--     utils.buf_only,
--     { desc = "Close all other buffers except current" }
-- )

api.nvim_create_user_command("Scratch",
    utils.create_scratch,
    { desc = "Create a new scratch buffer" }
)

-- api.nvim_create_user_command("CloneBuffer",
--     "new | 0put =getbufline('#',1,'$')",
--     { desc = "Clone current buffer content to a new split" }
-- )

-- Miscellaneous / System
-- --------------------------------------------------------------------------
-- api.nvim_create_user_command("Run",
--     utils.run_code,
--     { desc = "Run code based on filetype (defined in utils)" }
-- )

api.nvim_create_user_command("Blockwise",
    utils.blockwise_clipboard,
    { desc = "Set clipboard register to blockwise mode" }
)

api.nvim_create_user_command("SaveAsRoot",
    "w !doas tee %",
    { desc = "Save current file as root (requires doas/sudo)" }
)

-- api.nvim_create_user_command("Syntax",
--     "syntax sync minlines=64",
--     { desc = "Force re-sync syntax highlighting" }
-- )

-- api.nvim_create_user_command("Mappings",
--     "edit ~/.config/nvim/lua/config/keymaps.lua",
--     { desc = "Quickly edit keymaps configuration" }
-- )

 -- Create Command for Editing Snippets
api.nvim_create_user_command("LuaSnipEdit", 
    function()
        require("luasnip.loaders.from_lua").edit_snippet_files()
    end, {}
)

-- Legacy Realtime (Autoread)
-- --------------------------------------------------------------------------
-- Forces Neovim to detect file changes on disk immediately
api.nvim_create_user_command("Realtime",
    function()
        vim.opt.autoread = true
        api.nvim_create_autocmd("CursorHold", { pattern = "*", command = "checktime" })
        api.nvim_feedkeys("lh", "n", false) -- Trigger a move to refresh
    end,
    { desc = "Enable realtime autoread (watch file changes)" }
)


-- ==========================================================================
-- 2. AUTOCOMMANDS
-- ==========================================================================

-- Define a group to prevent duplicating autocmds on reload
local general                                   = api.nvim_create_augroup("GeneralSettings", { clear = true })

-- Highlight on Yank
-- --------------------------------------------------------------------------
-- Provides visual feedback when copying text.
api.nvim_create_autocmd("TextYankPost", {
    group                                       = general,
    callback                                    = function()
        vim.highlight.on_yank({
            higroup                             = "IncSearch",  -- Highlight group
            timeout                             = 300           -- Duration in ms
        })
    end,
})

-- Resize Splits
-- --------------------------------------------------------------------------
-- Automatically equalizes split sizes when the terminal window is resized.
api.nvim_create_autocmd({ "VimResized" }, {
    group                                       = general,
    callback                                    = function()
        vim.cmd("tabdo wincmd =")
    end,
})

-- Restore Cursor Position
-- --------------------------------------------------------------------------
-- Jumps to the last known cursor position when opening a file.
api.nvim_create_autocmd("BufReadPost", {
    group                                       = general,
    callback                                    = function()
        local mark                              = vim.api.nvim_buf_get_mark(0, '"')
        local lcount                            = vim.api.nvim_buf_line_count(0)
        if mark[1] > 0 and mark[1] <= lcount then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})

-- Close with 'q'
-- --------------------------------------------------------------------------
-- Makes it easier to close help windows, man pages, and quickfix lists.
api.nvim_create_autocmd("FileType", {
    group                                       = general,
    pattern                                     = {
        "qf",
        "help",
        "man",
        "lspinfo",
        "spectre_panel",
        "tsplayground"
    },
    callback                                    = function(event)
        vim.bo[event.buf].buflisted             = false
        vim.keymap.set("n", "q", "<cmd>close<cr>", {
            buffer                              = event.buf,
            silent                              = true
        })
    end,
})

-- Auto-Create Directories
-- --------------------------------------------------------------------------
-- Automatically creates missing directory structure when saving a file.
api.nvim_create_autocmd("BufWritePre", {
    group                                       = general,
    callback                                    = function(event)
        if event.match:match("^%w%w+://") then return end -- Skip remote files/URLs
        local file                              = vim.loop.fs_realpath(event.match) or event.match
        vim.fn.mkdir(vim.fn.fnamemodify(file, ":p:h"), "p")
    end,
})

-- Terminal Settings
-- --------------------------------------------------------------------------
-- Removes line numbers and enters Insert mode automatically in terminal buffers.
-- api.nvim_create_autocmd("TermOpen", {
--     group                                       = general,
--     pattern                                     = "*",
--     callback                                    = function()
--         vim.opt_local.number                    = false
--         vim.opt_local.relativenumber            = false
--         vim.opt_local.signcolumn                = "no"
--         vim.cmd("startinsert")
--     end,
-- })

-- Update Header
-- --------------------------------------------------------------------------
-- Updates "Last Modified" timestamp in file headers (requires utils.change_header).
-- api.nvim_create_autocmd("BufWritePre", {
--     group                                       = general,
--     callback                                    = utils.change_header,
-- })

-- Custom Filetypes
-- --------------------------------------------------------------------------
api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern                                     = { "*.conf", "config" },
    command                                     = "set filetype=config",
})

api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
    pattern                                     = "*.ejs",
    command                                     = "set filetype=html",
})

-- Large File Optimization
-- --------------------------------------------------------------------------
-- Disables heavy features (Syntax, Treesitter) for files > 20,000 lines.
api.nvim_create_autocmd("BufEnter", {
    group                                       = general,
    pattern                                     = "*",
    callback                                    = function()
        if vim.api.nvim_buf_line_count(0) > 20000 then
            vim.cmd("syntax off")
            vim.cmd("TSDisable") -- Note: Ensure TSDisable command exists or use pcall
        end
    end,
})

-- Echo Filename (Optional)
-- --------------------------------------------------------------------------
-- Echoes the filename when entering a buffer (Commented out by default).
-- api.nvim_create_autocmd("BufEnter", {
--     group                                       = general,
--     pattern                                     = "*",
--     callback                                    = function()
--         local name                              = vim.fn.expand("%:t")
--         local ft                                = vim.bo.filetype
--         if ft ~= "NvimTree" and ft ~= "TelescopePrompt" and name ~= "" then
--             print(name)
--         end
--     end,
-- })

-- Starts the Toggler Fucntion
api.nvim_create_autocmd("InsertEnter", {
    once = true, -- Ensures this only runs the first time you enter Insert mode
    callback = function()
        local toggler = require("util.toggler") -- Replace with your actual file path
        toggler.setup(env_config.toggles or {})
        vim.keymap.set({"n", "v"}, "<leader>t", toggler.toggle, { desc = "Toggle word" })
    end,
})
