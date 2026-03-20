-- ==========================================================================
-- CUSTOM DASHBOARD (Optimized)
-- ==========================================================================
-- lua/core/dashboard.lua
-- Pro-tier: Uses deferred rendering (vim.schedule) for instant startup time.

local Dash = {}

function Dash.setup()
    -- Create Group Once
    local augroup = vim.api.nvim_create_augroup("Dashboard", { clear = true })

    vim.api.nvim_create_autocmd("VimEnter", {
        group = augroup,
        once = true, -- Optimization: This only needs to run once per session
        callback = function()
            -- ----------------------------------------------------------------------
            -- 1. Instant Pre-conditions (Fail Fast)
            -- ----------------------------------------------------------------------
            -- Check argc (files passed via command line)
            if vim.fn.argc() > 0 then return end

            -- Check if buffer is truly empty (Checking byte count is faster than getting lines)
            -- -1 means empty buffer in some contexts, or line 1 is empty.
            if vim.fn.line2byte('$') ~= -1 then return end

            -- ----------------------------------------------------------------------
            -- 2. Defer Execution (The Speed Fix)
            -- ----------------------------------------------------------------------
            -- vim.schedule pushes the UI drawing to the "next tick".
            -- This allows Neovim to finish its internal "Startup" timer immediately.
            vim.schedule(function()
                local buf = vim.api.nvim_create_buf(false, true)

                -- Buffer Settings
                local bo = vim.bo[buf]
                bo.bufhidden = "wipe"
                bo.buftype = "nofile"
                bo.filetype = "dashboard"
                bo.swapfile = false

                -- Set Buffer to Window
                vim.api.nvim_win_set_buf(0, buf)

                -- Window Options (Clean UI)
                local wo = vim.opt_local
                wo.number = false
                wo.relativenumber = false
                wo.cursorline = false
                wo.cursorcolumn = false
                wo.signcolumn = "no"
                wo.list = false
                wo.fillchars = { eob = " " }

                -- ------------------------------------------------------------------
                -- 3. Cursor Hiding (Robust)
                -- ------------------------------------------------------------------
                local original_guicursor = vim.o.guicursor
                -- Create invisible highlight group
                vim.api.nvim_set_hl(0, "DashboardCursor", { blend = 100, nocombine = true })

                local function hide_cursor()
                    if vim.o.guicursor ~= "a:DashboardCursor" then
                        vim.opt.guicursor = "a:DashboardCursor"
                    end
                end

                local function restore_cursor()
                    vim.opt.guicursor = original_guicursor
                end

                hide_cursor()

                -- Auto-Restore events
                vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "VimLeavePre" }, {
                    buffer = buf,
                    callback = restore_cursor,
                })

                vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
                    buffer = buf,
                    callback = hide_cursor,
                })

                -- ------------------------------------------------------------------
                -- 4. Content Rendering
                -- ------------------------------------------------------------------
                local logo = {
                    " /$$        /$$$$$$   /$$$$$$   /$$$ ",
                    "| $$       /$$$_  $$ /$$$_  $$ /$$$$ ",
                    "| $$$$$$$ | $$$$\\ $$| $$$$\\ $$|_  $$ ",
                    "| $$__  $$| $$ $$ $$| $$ $$ $$  | $$ ",
                    "| $$  \\ $$| $$\\ $$$$| $$\\ $$$$  | $$ ",
                    "| $$  | $$| $$ \\ $$$| $$ \\ $$$  | $$ ",
                    "| $$$$$$$/|  $$$$$$/|  $$$$$$/ /$$$$$$",
                    "|_______/  \\______/  \\______/ |______/",
                    "                                      ",
                }

                local menu = {
                    " [e] New File ",
                    " [f] Find File",
                    " [q] Quit     ",
                }

                local width = vim.api.nvim_win_get_width(0)
                local height = vim.api.nvim_win_get_height(0)

                -- Inline optimized center function
                local content = {}

                -- Add Top Padding
                local total_lines = #logo + #menu + 2
                local top_pad = math.max(0, math.floor((height - total_lines) / 2))
                for _ = 1, top_pad do table.insert(content, "") end

                -- Center & Add Logo
                for _, line in ipairs(logo) do
                    local pad = math.max(0, math.floor((width - #line) / 2))
                    table.insert(content, string.rep(" ", pad) .. line)
                end

                -- Spacers
                table.insert(content, "")
                table.insert(content, "")

                -- Center & Add Menu
                for _, line in ipairs(menu) do
                    local pad = math.max(0, math.floor((width - #line) / 2))
                    table.insert(content, string.rep(" ", pad) .. line)
                end

                -- Render
                vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
                bo.modifiable = false

                -- ------------------------------------------------------------------
                -- 5. Keymaps
                -- ------------------------------------------------------------------
                local opts = { buffer = buf, noremap = true, silent = true }

                -- [e] New File
                vim.keymap.set("n", "e", function()
                    restore_cursor()
                    vim.cmd("enew")
                end, opts)

                -- [f] Find File (Safe)
                vim.keymap.set("n", "f", function()
                    restore_cursor()
                    if _G.Snacks then
                        Snacks.picker.files()
                    elseif pcall(require, "telescope") then
                        vim.cmd("Telescope find_files")
                    else
                        -- Fallback for safety
                        local f = vim.fn.input("Find file: ", "", "file")
                        if f ~= "" then vim.cmd("edit " .. f) end
                    end
                end, opts)

                -- [q] Quit
                vim.keymap.set("n", "q", ":q!<CR>", opts)
            end) -- End vim.schedule
        end,
    })
end

return Dash
