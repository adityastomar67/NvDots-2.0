-- ==========================================================================
-- UTILITY FUNCTIONS
-- ==========================================================================
-- lua/core/utils.lua
-- This module contains helper functions used by autocommands and keymaps.
-- It handles text manipulation, buffer management, and system tasks.

local Utils                                     = {}

-- ==========================================================================
-- 1. TEXT MANIPULATION
-- ==========================================================================

-- Preserve View
-- --------------------------------------------------------------------------
-- Runs a command (usually a substitution) without moving the cursor or
-- messing up the jump list/search history.
Utils.preserve = function(cmd)
    cmd                                         = string.format("keepjumps keeppatterns execute %q", cmd)
    local line, col                             = unpack(vim.api.nvim_win_get_cursor(0))

    vim.api.nvim_command(cmd)

    local lastline                              = vim.fn.line("$")
    if line > lastline then
        line                                    = lastline
    end

    vim.api.nvim_win_set_cursor(0, { line, col })
end

-- Dos2Unix
-- --------------------------------------------------------------------------
-- Converts DOS line endings (CRLF) to Unix (LF) and sets encoding to UTF-8.
Utils.dos_to_unix = function()
    M.preserve("%s/\\%x0D$//e") -- Remove \r characters
    vim.bo.fileformat                           = "unix"
    vim.bo.bomb                                 = true
    vim.opt.encoding                            = "utf-8"
    vim.opt.fileencoding                        = "utf-8"
    vim.notify("Converted to Unix format", vim.log.levels.INFO)
end

-- Squeeze Blank Lines
-- --------------------------------------------------------------------------
-- Removes consecutive blank lines, leaving only one.
-- Skips binary files and diff buffers to prevent data corruption.
Utils.squeeze_blank_lines = function()
    if not vim.bo.binary and vim.bo.filetype ~= "diff" then
        M.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn")               -- Report matches
        M.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge")     -- Replace consecutive newlines
        M.preserve("sil! keepp keepj %s/^\\s\\+$/\\r/ge")       -- Clear lines with only whitespace
        M.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e")-- Clean up end of file
    end
end

-- Re-indent File
-- --------------------------------------------------------------------------
-- Re-indents the entire file using the internal formatter (gg=G).
Utils.reindent = function()
    Utils.preserve("sil keepj normal! gg=G")
    vim.notify("File re-indented", vim.log.levels.INFO)
end

-- Update Header Date
-- --------------------------------------------------------------------------
-- Automatically updates "Last Modified: ..." timestamp in the first 7 lines.
Utils.change_header = function()
    -- Check if buffer is modifiable
    if not vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "modifiable") then
        return
    end

    -- Scan the first 7 lines
    if vim.fn.line("$") >= 7 then
        os.setlocale("en_US.UTF-8")
        local time                              = os.date("%a, %d %b %Y %H:%M")
        -- Search for "last modified:" or "last change:" and update the date
        Utils.preserve("sil! keepp keepj 1,7s/\\vlast (modified|change):\\zs.*/ " .. time .. "/ei")
    end
end

-- ==========================================================================
-- 2. BUFFER MANAGEMENT
-- ==========================================================================

-- Close Other Buffers
-- --------------------------------------------------------------------------
-- Closes all buffers except the current one. Useful for decluttering.
Utils.buf_only = function()
    Utils.preserve("silent! %bd|e#|bd#")
    vim.notify("Buffers cleared", vim.log.levels.INFO)
end

-- Quick Scratch Buffer
-- --------------------------------------------------------------------------
-- Creates a temporary buffer that is not listed and doesn't save to disk.
Utils.create_scratch = function()
    vim.cmd("new")
    vim.opt_local.buftype                       = "nofile"
    vim.opt_local.bufhidden                     = "wipe"
    vim.opt_local.buflisted                     = false
    vim.opt_local.swapfile                      = false
    vim.opt_local.number                        = true
end

-- Blockwise Clipboard
-- --------------------------------------------------------------------------
-- Forces the system clipboard content to be treated as a block (Ctrl+V style)
-- when pasting.
Utils.blockwise_clipboard = function()
    vim.cmd("call setreg('+', @+, 'b')")
    vim.notify("Clipboard set to blockwise", vim.log.levels.INFO)
end

-- ==========================================================================
-- 3. VISUAL & EXECUTION
-- ==========================================================================

-- Flash Cursor Line
-- --------------------------------------------------------------------------
-- Briefly highlights the current line. Useful for orientation.
Utils.flash_cursorline = function()
    local cursorline_state                      = vim.opt.cursorline:get()
    vim.opt.cursorline                          = true
    
    vim.cmd([[hi CursorLine guifg=#FFFFFF guibg=#FF9509]])
    
    vim.fn.timer_start(200, function()
        vim.cmd([[hi CursorLine guifg=NONE guibg=NONE]])
        if not cursorline_state then
            vim.opt.cursorline                  = false
        end
    end)
end

-- Code Runner
-- --------------------------------------------------------------------------
-- Executes the current file based on its filetype in a split terminal.
Utils.run_code = function()
    local ft                                    = vim.bo.filetype
    local file                                  = vim.fn.expand("%")

    -- Mapping filetypes to execution commands
    local commands = {
        python                                  = "python3 " .. file,
        lua                                     = "lua " .. file,
        sh                                      = "bash " .. file,
        zsh                                     = "zsh " .. file,
        javascript                              = "node " .. file,
        typescript                              = "ts-node " .. file,
        rust                                    = "cargo run",
        go                                      = "go run " .. file,
        cpp                                     = "g++ -std=c++20 " .. file .. " && ./a.out && rm -f a.out",
    }

    if commands[ft] then
        -- Opens in a vertical split terminal
        vim.cmd("vsplit | term " .. commands[ft])
    else
        vim.notify("No runner configured for " .. ft, vim.log.levels.WARN)
    end
end

return Utils
