-- ==========================================================================
-- CUSTOM DASHBOARD
-- ==========================================================================
-- lua/core/dashboard.lua
-- A lightweight, dependency-free dashboard that appears on startup.
-- Includes logic to center text and hide the cursor for a clean look.

local Dash = {}

function Dash.setup()
    vim.api.nvim_create_autocmd("VimEnter", {
        group                                   = vim.api.nvim_create_augroup("Dashboard", { clear = true }),
        callback = function()
            -- ----------------------------------------------------------------------
            -- 1. Check Pre-conditions
            -- ----------------------------------------------------------------------
            -- Don't show dashboard if opening a file (nvim file.txt) or reading from stdin
            if vim.fn.argc() > 0 then return end

            -- Don't show if the buffer already has content
            local lines                         = vim.api.nvim_buf_get_lines(0, 0, -1, false)
            if #lines > 1 or (#lines == 1 and #lines[1] > 0) then return end

            -- ----------------------------------------------------------------------
            -- 2. Create and Setup Buffer
            -- ----------------------------------------------------------------------
            local buf                           = vim.api.nvim_create_buf(false, true)
            vim.bo[buf].bufhidden               = "wipe"        -- Wipe buffer when hidden
            vim.bo[buf].buftype                 = "nofile"      -- Not a real file
            vim.bo[buf].filetype                = "dashboard"   -- Custom filetype

            -- Set the current window to use this new buffer
            vim.api.nvim_win_set_buf(0, buf)

            -- ----------------------------------------------------------------------
            -- 3. Clean UI Options
            -- ----------------------------------------------------------------------
            -- Disable standard UI elements for a cleaner look
            local win                           = 0 -- Current window
            vim.opt_local.number                = false
            vim.opt_local.relativenumber        = false
            vim.opt_local.cursorline            = false
            vim.opt_local.cursorcolumn          = false
            vim.opt_local.signcolumn            = "no"
            vim.opt_local.fillchars             = { eob = " " } -- Hide "~" at end of buffer

            -- ======================================================================
            -- 4. CURSOR HIDING MAGIC
            -- ======================================================================
            -- This section makes the cursor invisible while inside the dashboard.

            -- Save the user's original cursor setting to restore later
            local original_guicursor            = vim.o.guicursor

            -- Create an invisible highlight group (requires termguicolors)
            -- blend=100 makes the background transparent/invisible
            vim.api.nvim_set_hl(0, "DashboardCursor", { blend = 100, nocombine = true })

            local function hide_cursor()
                -- Set cursor to use the invisible highlight group in all modes ("a")
                vim.opt.guicursor               = "a:DashboardCursor"
            end

            local function restore_cursor()
                vim.opt.guicursor               = original_guicursor
            end

            -- Apply immediately
            hide_cursor()

            -- Event: Restore cursor when leaving dashboard or quitting
            vim.api.nvim_create_autocmd({ "BufLeave", "WinLeave", "VimLeavePre" }, {
                buffer                          = buf,
                callback                        = restore_cursor,
            })

            -- Event: Re-hide cursor if user switches back to dashboard
            vim.api.nvim_create_autocmd({ "BufEnter", "WinEnter" }, {
                buffer                          = buf,
                callback                        = hide_cursor,
            })

            -- ======================================================================
            -- 5. Content Rendering
            -- ======================================================================

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

            -- Calculation for centering
            local width                         = vim.api.nvim_win_get_width(win)
            local height                        = vim.api.nvim_win_get_height(win)

            local function center(text_lines)
                local res                       = {}
                for _, line in ipairs(text_lines) do
                    local pad                   = math.floor((width - #line) / 2)
                    table.insert(res, string.rep(" ", pad) .. line)
                end
                return res
            end

            local content                       = {}
            local total_lines                   = #logo + #menu + 2
            local top_pad                       = math.floor((height - total_lines) / 2)

            -- Build the content table
            for _ = 1, top_pad do table.insert(content, "") end
            for _, l in ipairs(center(logo)) do table.insert(content, l) end
            table.insert(content, "") -- Spacer
            table.insert(content, "") -- Spacer
            for _, l in ipairs(center(menu)) do table.insert(content, l) end

            -- Write to buffer & lock it
            vim.api.nvim_buf_set_lines(buf, 0, -1, false, content)
            vim.bo[buf].modifiable              = false

            -- ----------------------------------------------------------------------
            -- 6. Keymaps
            -- ----------------------------------------------------------------------
            local opts                          = { buffer = buf, noremap = true, silent = true }

            -- New File
            vim.keymap.set("n", "e", function()
                restore_cursor()
                vim.cmd("enew")
            end, opts)

            -- Find File (Telescope)
            vim.keymap.set("n", "f", function()
                -- GUARD CLAUSE: Check if Telescope is installed
                -- vim.fn.exists(":Telescope") returns 2 if the command exists
                if vim.fn.exists(":Telescope") == 0 then
                    vim.notify("Dashboard: 'nvim-telescope/telescope.nvim' is not installed.", 
                    vim.log.levels.WARN)
                    return
                end

                restore_cursor()
                vim.cmd("Telescope find_files")
            end, opts)

            -- Quit
            vim.keymap.set("n", "q", ":q!<CR>", opts)
        end,
    })
end

return Dash
