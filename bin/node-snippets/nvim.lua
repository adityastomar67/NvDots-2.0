-- ==========================================================================
-- LUA SNIPPETS (NEOVIM FOCUSED)
-- ==========================================================================
-- lua/snippets/lua.lua

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    lua = {
        -- ======================================================================
        -- 1. REQUIRES & MODULES
        -- ======================================================================
        -- Safe Require
        ns.snippet("pcall", {
            ns.text_node("local status_ok, "),
            ns.insert_node(1, "name"),
            ns.text_node(" = pcall(require, \""),
            ns.insert_node(2, "module"),
            ns.text_node({ "\")", "if not status_ok then", "\treturn", "end", "" }),
            ns.insert_node(0),
        }),

        -- Module Boilerplate
        -- TODO: Add the snippet to get the name of usr choice rather than M
        ns.snippet("mod", {
            ns.text_node({ "local M = {}", "", "M.setup = function()", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "end", "", "return M" }),
        }),

        -- ======================================================================
        -- 2. VIM CORE OPTIONS & COMMANDS
        -- ======================================================================
        
        -- Vim Command (vim.cmd)
        ns.snippet("cmd", {
            ns.text_node("vim.cmd([["),
            ns.insert_node(1, "command"),
            ns.text_node("]])"),
        }),

        -- Vim Option (vim.opt)
        ns.snippet("opt", {
            ns.text_node("vim.opt."),
            ns.insert_node(1, "option"),
            ns.text_node(" = "),
            ns.insert_node(2, "value"),
        }),

        -- Global Variable (vim.g)
        ns.snippet("gvar", {
            ns.text_node("vim.g."),
            ns.insert_node(1, "variable_name"),
            ns.text_node(" = "),
            ns.insert_node(2, "value"),
        }),

        -- Function Call (vim.fn)
        ns.snippet("fn", {
            ns.text_node("vim.fn."),
            ns.insert_node(1, "function_name"),
            ns.text_node("("),
            ns.insert_node(2),
            ns.text_node(")"),
        }),

        -- ======================================================================
        -- 3. NEOVIM API (Keymaps, Autocmds, Highlights)
        -- ======================================================================

        -- Keymap (Short)
        ns.snippet("map", {
            ns.text_node("vim.keymap.set(\""),
            ns.insert_node(1, "n"),
            ns.text_node("\", \""),
            ns.insert_node(2, "<leader>"),
            ns.text_node("\", "),
            ns.insert_node(3, "command"),
            ns.text_node(", { desc = \""),
            ns.insert_node(4, "Description"),
            ns.text_node("\" })"),
        }),

        -- Create User Command (:Command)
        ns.snippet("ucmd", {
            ns.text_node("vim.api.nvim_create_user_command(\""),
            ns.insert_node(1, "CommandName"),
            ns.text_node("\", function(opts)"),
            ns.text_node({ "", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "end, { desc = \"" }),
            ns.insert_node(2, "Description"),
            ns.text_node("\" })"),
        }),

        -- Autocmd Group
        ns.snippet("augroup", {
            ns.text_node("local "),
            ns.insert_node(1, "group_name"),
            ns.text_node(" = vim.api.nvim_create_augroup(\""),
            ns.insert_node(2, "GroupName"),
            ns.text_node("\", { clear = true })"),
        }),

        -- Autocmd (Complete)
        ns.snippet("aucmd", {
            ns.text_node("vim.api.nvim_create_autocmd(\""),
            ns.insert_node(1, "BufRead"),
            ns.text_node({ "\", {", "\tgroup = " }),
            ns.insert_node(2, "group_var"),
            ns.text_node({ ",", "\tpattern = \"" }),
            ns.insert_node(3, "*"),
            ns.text_node({ "\",", "\tcallback = function(ev)", "\t\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "\tend,", "})" }),
        }),

        -- Set Highlight Group
        ns.snippet("hl", {
            ns.text_node("vim.api.nvim_set_hl(0, \""),
            ns.insert_node(1, "GroupName"),
            ns.text_node("\", { fg = \""),
            ns.insert_node(2, "#ffffff"),
            ns.text_node("\", bg = \""),
            ns.insert_node(3, "NONE"),
            ns.text_node("\", bold = "),
            ns.insert_node(4, "true"),
            ns.text_node(" })"),
        }),

        -- ======================================================================
        -- 4. UI & NOTIFICATIONS
        -- ======================================================================

        -- Notification
        ns.snippet("notify", {
            ns.text_node("vim.notify(\""),
            ns.insert_node(1, "Message"),
            ns.text_node("\", vim.log.levels."),
            ns.insert_node(2, "INFO"),
            ns.text_node(", { title = \""),
            ns.insert_node(3, "Title"),
            ns.text_node("\" })"),
        }),

        -- UI Select (List Picker)
        ns.snippet("select", {
            ns.text_node("vim.ui.select("),
            ns.insert_node(1, "items_table"),
            ns.text_node(", { prompt = \""),
            ns.insert_node(2, "Select item:"),
            ns.text_node("\" }, function(choice)"),
            ns.text_node({ "", "\tif not choice then return end", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "end)" }),
        }),

        -- UI Input (Text Input)
        ns.snippet("input", {
            ns.text_node("vim.ui.input({ prompt = \""),
            ns.insert_node(1, "Enter value: "),
            ns.text_node("\" }, function(input)"),
            ns.text_node({ "", "\tif not input then return end", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "end)" }),
        }),

        -- ======================================================================
        -- 5. LAZY.NVIM PLUGIN SPECS
        -- ======================================================================
        
        -- Basic Plugin Spec
        ns.snippet("lazy", {
            ns.text_node("{"),
            ns.text_node({ "", "\t\"" }),
            ns.insert_node(1, "author/repo"),
            ns.text_node("\","),
            ns.text_node({ "", "\tevent = \"" }),
            ns.insert_node(2, "VeryLazy"),
            ns.text_node("\","),
            ns.text_node({ "", "\topts = {" }),
            ns.text_node({ "", "\t\t" }),
            ns.insert_node(3),
            ns.text_node({ "", "\t}," }),
            ns.text_node({ "", "}," }),
        }),

        -- Full Plugin Spec (with keys & config)
        ns.snippet("lazyfull", {
            ns.text_node("{"),
            ns.text_node({ "", "\t\"" }),
            ns.insert_node(1, "author/repo"),
            ns.text_node("\","),
            ns.text_node({ "", "\tevent = \"" }),
            ns.insert_node(2, "BufReadPre"),
            ns.text_node("\","),
            ns.text_node({ "", "\tkeys = {" }),
            ns.text_node({ "", "\t\t{ \"" }),
            ns.insert_node(3, "<leader>key"),
            ns.text_node("\", desc = \""),
            ns.insert_node(4, "Desc"),
            ns.text_node("\" }, to"),
            ns.text_node({ "", "\t}," }),
            ns.text_node({ "", "\tconfig = function()", "\t\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "\tend,", "}," }),
        }),

        -- ======================================================================
        -- 6. GENERAL LUA UTILS
        -- ======================================================================

        -- Inspect/Print
        ns.snippet("log", {
            ns.text_node("print(vim.inspect("),
            ns.insert_node(1, "variable"),
            ns.text_node("))"),
        }),

        -- Protected Call
        ns.snippet("xpcall", {
            ns.text_node("xpcall(function()"),
            ns.text_node({ "", "\t" }),
            ns.insert_node(1, "code"),
            ns.text_node({ "", "end, function(err)", "\tprint(\"Error: \" .. tostring(err))", "end)" }),
        }),
    }
}
