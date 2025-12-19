-- ==========================================================================
-- CORE UTILITIES
-- ==========================================================================
-- lua/core/utils.lua
-- This module contains helper functions used by autocommands, keymaps,
-- and LuaSnip configuration. It handles text manipulation, buffer
-- management, and system tasks.

local Utils = {}

-- ==========================================================================
-- 1. LUASNIP MODULE DEFINITIONS
-- ==========================================================================
-- Mapping LuaSnip internal modules to a table for easier access throughout
-- the configuration. This abstracts the 'require' calls.

Utils.node_snip = setmetatable({}, {
    __index = function(tbl, key)
        -- 1. Load LuaSnip modules ONLY when a key is accessed
        local ls = require("luasnip")
        local extras = require("luasnip.extras")
        local fmt = require("luasnip.extras.fmt")

        -- 2. Define the full map
        local modules = {
            -- Core
            ls               = ls,
            snippet          = ls.snippet,
            snip_node        = ls.snippet_node,
            text_node        = ls.text_node,
            insert_node      = ls.insert_node,
            func_node        = ls.function_node,
            choice_node      = ls.choice_node,
            dynamic_node     = ls.dynamic_node,

            -- Extras
            lambda           = extras.lambda,
            rep              = extras.rep,
            partial          = extras.partial,
            match            = extras.match,
            non_empty        = extras.nonempty,
            dynamic_lambda   = extras.dynamic_lambda,

            -- Formatting
            fmt              = fmt.fmt,
            fmta             = fmt.fmta,
            isn              = ls.indent_snippet_node,

            -- Utils
            types            = require("luasnip.util.types"),
            conds            = require("luasnip.extras.expand_conditions"),
            events           = require("luasnip.util.events"),
        }

        -- 3. Cache ALL keys so this function never runs again
        for k, v in pairs(modules) do
            rawset(tbl, k, v)
        end

        -- 4. Return the requested key
        return modules[key]
    end
})

-- ==========================================================================
-- 2. LUASNIP HELPER FUNCTIONS (SIMPLE)
-- ==========================================================================

---Simply returns the content of the first argument.
---Useful for mirroring text in function nodes.
---@param args table
---@return string
Utils.copy = function(args)
    return args[1]
end

---Returns a snippet node containing the current date.
---@param args table
---@param state table
---@param fmt string|nil Date format (default: "%Y-%m-%d")
Utils.date_input = function(args, state, fmt)
    local format = fmt or "%Y-%m-%d"
    return Utils.node_snip.snip_node(nil, Utils.node_snip.insert_node(1, os.date(format)))
end

---Executes a bash command and returns the output as a table.
---WARNING: This is blocking. Do not use for long-running commands.
---@param command string
---@return table
Utils.bash = function(_, _, command)
    local file = io.popen(command, "r")
    local res = {}
    for line in file:lines() do
        table.insert(res, line)
    end
    return res
end

---Partial application helper function.
---Used to pre-fill arguments for other functions.
Utils.part = function(func, ...)
    local args = { ... }
    return function()
        return func(unpack(args))
    end
end

---Creates a paired snippet (e.g., brackets) with conditional expansion logic.
---@param pair_begin string The starting character (e.g., "(")
---@param pair_end string The ending character (e.g., ")")
---@param expand_func function The condition function
Utils.pair = function(pair_begin, pair_end, expand_func, ...)
    return Utils.node_snip.snippet(
        { trig = pair_begin, wordTrig = false },
        {
            Utils.node_snip.text_node({ pair_begin }),
            Utils.node_snip.insert_node(1),
            Utils.node_snip.text_node({ pair_end }),
        },
        {
            condition = Utils.part(expand_func, Utils.part(..., pair_begin, pair_end))
        }
    )
end

-- ==========================================================================
-- 3. LUASNIP HELPER FUNCTIONS (COMPLEX)
-- ==========================================================================

---Dynamic node generator for JavaDoc style comments.
---Parses function arguments to create @param and @return tags.
Utils.jdocsnip = function(args, _, old_state)

    local nodes = {
        Utils.node_snip.text_node({ "/**", " * " }),
        Utils.node_snip.insert_node(1, "A short Description"),
        Utils.node_snip.text_node({ "", "" }),
    }

    -- Preserve user edits if snippet is updated
    local param_nodes = {}
    if old_state then
        nodes[2] = Utils.node_snip.insert_node(1, old_state.descr:get_text())
    end
    param_nodes.descr = nodes[2]

    -- Add separator if params exist
    if string.find(args[2][1], ", ") then
        vim.list_extend(nodes, { Utils.node_snip.text_node({ " * ", "" }) })
    end

    local insert = 2
    for _, arg in ipairs(vim.split(args[2][1], ", ", true)) do
        arg = vim.split(arg, " ", true)[2] -- Get variable name
        if arg then
            local inode
            if old_state and old_state["arg" .. arg] then
                inode = Utils.node_snip.insert_node(insert, old_state["arg" .. arg]:get_text())
            else
                inode = Utils.node_snip.insert_node(insert)
            end
            vim.list_extend(nodes, {
                Utils.node_snip.text_node({ " * @param " .. arg .. " " }),
                inode,
                Utils.node_snip.text_node({ "", "" }),
            })
            param_nodes["arg" .. arg] = inode
            insert = insert + 1
        end
    end

    if args[1][1] ~= "void" then
        local inode
        if old_state and old_state.ret then
            inode = Utils.node_snip.insert_node(insert, old_state.ret:get_text())
        else
            inode = Utils.node_snip.insert_node(insert)
        end
        vim.list_extend(nodes, {
            Utils.node_snip.text_node({ " * ", " * @return " }),
            inode,
            Utils.node_snip.text_node({ "", "" }),
        })
        param_nodes.ret = inode
        insert = insert + 1
    end

    if vim.tbl_count(args[3]) ~= 1 then
        local exc = string.gsub(args[3][2], " throws ", "")
        local ins
        if old_state and old_state.ex then
            ins = Utils.node_snip.insert_node(insert, old_state.ex:get_text())
        else
            ins = Utils.node_snip.insert_node(insert)
        end
        vim.list_extend(nodes, {
            Utils.node_snip.text_node({ " * ", " * @throws " .. exc .. " " }),
            ins,
            Utils.node_snip.text_node({ "", "" }),
        })
        param_nodes.ex = ins
        insert = insert + 1
    end

    vim.list_extend(nodes, { Utils.node_snip.text_node({ " */" }) })

    local snip = Utils.node_snip.snip_node(nil, nodes)
    snip.old_state = param_nodes
    return snip
end

---Dynamic node generator for LuaDoc style comments.
---Similar to jdocsnip but formatted for Lua annotations.
Utils.luadocsnip = function(args, _, old_state)

    local nodes = {
        Utils.node_snip.text_node({ "--- ", "" }),
        Utils.node_snip.insert_node(1, "A short Description"),
        Utils.node_snip.text_node({ "", "" }),
    }

    local param_nodes = {}
    if old_state then
        nodes[2] = Utils.node_snip.insert_node(1, old_state.descr:get_text())
    end
    param_nodes.descr = nodes[2]

    if string.find(args[2][1], ", ") then
        vim.list_extend(nodes, { Utils.node_snip.text_node({ "--- ", "" }) })
    end

    local insert = 2
    for _, arg in ipairs(vim.split(args[2][1], ", ", true)) do
        arg = vim.split(arg, " ", true)[2]
        if arg then
            local inode
            if old_state and old_state["arg" .. arg] then
                inode = Utils.node_snip.insert_node(insert, old_state["arg" .. arg]:get_text())
            else
                inode = Utils.node_snip.insert_node(insert)
            end
            vim.list_extend(nodes, {
                Utils.node_snip.text_node({ "--- @param " .. arg .. " " }),
                inode,
                Utils.node_snip.text_node({ "", "" }),
            })
            param_nodes["arg" .. arg] = inode
            insert = insert + 1
        end
    end

    if args[1][1] ~= "void" then
        local inode
        if old_state and old_state.ret then
            inode = Utils.node_snip.insert_node(insert, old_state.ret:get_text())
        else
            inode = Utils.node_snip.insert_node(insert)
        end
        vim.list_extend(nodes, {
            Utils.node_snip.text_node({ "--- ", "--- @return " }),
            inode,
            Utils.node_snip.text_node({ "", "" }),
        })
        param_nodes.ret = inode
        insert = insert + 1
    end

    -- Lua doesn't typically use 'throws' in signatures, but kept for parity
    if vim.tbl_count(args[3]) ~= 1 then
        local exc = string.gsub(args[3][2], " throws ", "")
        local ins
        if old_state and old_state.ex then
            ins = Utils.node_snip.insert_node(insert, old_state.ex:get_text())
        else
            ins = Utils.node_snip.insert_node(insert)
        end
        vim.list_extend(nodes, {
            Utils.node_snip.text_node({ "--- ", "--- @throws " .. exc .. " " }),
            ins,
            Utils.node_snip.text_node({ "", "" }),
        })
        param_nodes.ex = ins
        insert = insert + 1
    end

    local snip = Utils.node_snip.snip_node(nil, nodes)
    snip.old_state = param_nodes
    return snip
end

-- ==========================================================================
-- 4. TEXT MANIPULATION
-- ==========================================================================

---Runs a command (usually a substitution) without moving the cursor or
---messing up the jump list/search history.
---@param cmd string The vim command to execute
Utils.preserve = function(cmd)
    cmd = string.format("keepjumps keeppatterns execute %q", cmd)
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))

    vim.api.nvim_command(cmd)

    local lastline = vim.fn.line("$")
    if line > lastline then
        line = lastline
    end

    vim.api.nvim_win_set_cursor(0, { line, col })
end

---Removes consecutive blank lines, leaving only one.
---Skips binary files and diff buffers to prevent data corruption.
Utils.squeeze_blank_lines = function()
    if not vim.bo.binary and vim.bo.filetype ~= "diff" then
        Utils.preserve("sil! 1,.s/^\\n\\{2,}/\\r/gn")           -- Report matches
        Utils.preserve("sil! keepp keepj %s/^\\n\\{2,}/\\r/ge") -- Replace consecutive newlines
        Utils.preserve("sil! keepp keepj %s/^\\s\\+$/\\r/ge")   -- Clear lines with only whitespace
        Utils.preserve("sil! keepp keepj %s/\\v($\\n\\s*)+%$/\\r/e") -- Clean up end of file
    end
end

---Re-indents the entire file using the internal formatter (gg=G).
Utils.reindent = function()
    Utils.preserve("sil keepj normal! gg=G")
    vim.notify("File re-indented", vim.log.levels.INFO)
end

-- [OPTIONAL] Converts DOS line endings to Unix
-- Utils.dos_to_unix = function()
--     Utils.preserve("%s/\\%x0D$//e")
--     vim.bo.fileformat = "unix"
--     vim.bo.bomb = true
--     vim.opt.encoding = "utf-8"
--     vim.opt.fileencoding = "utf-8"
--     vim.notify("Converted to Unix format", vim.log.levels.INFO)
-- end

-- [OPTIONAL] Updates "Last Modified" timestamp in header
-- Utils.change_header = function()
--     if not vim.api.nvim_buf_get_option(vim.api.nvim_get_current_buf(), "modifiable") then return end
--     if vim.fn.line("$") >= 7 then
--         os.setlocale("en_US.UTF-8")
--         local time = os.date("%a, %d %b %Y %H:%M")
--         Utils.preserve("sil! keepp keepj 1,7s/\\vlast (modified|change):\\zs.*/ " .. time .. "/ei")
--     end
-- end

-- ==========================================================================
-- 5. BUFFER MANAGEMENT
-- ==========================================================================

---Creates a temporary scratch buffer.
---Not listed, no swapfile, wipes on hide.
Utils.create_scratch = function()
    vim.cmd("new")
    vim.opt_local.buftype   = "nofile"
    vim.opt_local.bufhidden = "wipe"
    vim.opt_local.buflisted = false
    vim.opt_local.swapfile  = false
    vim.opt_local.number    = true
end

---Forces the system clipboard content to be treated as a block (Ctrl+V style).
Utils.blockwise_clipboard = function()
    vim.cmd("call setreg('+', @+, 'b')")
    vim.notify("Clipboard set to blockwise", vim.log.levels.INFO)
end

-- [OPTIONAL] Close all other buffers
-- Utils.buf_only = function()
--     Utils.preserve("silent! %bd|e#|bd#")
--     vim.notify("Buffers cleared", vim.log.levels.INFO)
-- end

-- ==========================================================================
-- 6. VISUAL & EXECUTION
-- ==========================================================================

-- [OPTIONAL] Flash Cursor Line
-- Utils.flash_cursorline = function()
--     local cursorline_state = vim.opt.cursorline:get()
--     vim.opt.cursorline = true
--     vim.cmd([[hi CursorLine guifg=#FFFFFF guibg=#FF9509]])
--     vim.fn.timer_start(200, function()
--         vim.cmd([[hi CursorLine guifg=NONE guibg=NONE]])
--         if not cursorline_state then vim.opt.cursorline = false end
--     end)
-- end

-- [OPTIONAL] Code Runner
-- Utils.run_code = function()
--     local ft = vim.bo.filetype
--     local file = vim.fn.expand("%")
--     local commands = {
--         python = "python3 " .. file,
--         lua = "lua " .. file,
--         sh = "bash " .. file,
--         rust = "cargo run",
--         go = "go run " .. file,
--     }
--     if commands[ft] then
--         vim.cmd("vsplit | term " .. commands[ft])
--     else
--         vim.notify("No runner configured for " .. ft, vim.log.levels.WARN)
--     end
-- end

return Utils
