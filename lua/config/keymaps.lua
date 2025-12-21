-- ==========================================================================
-- KEYMAPPINGS CONFIGURATION
-- ==========================================================================
-- lua/config/keymaps.lua
-- This file handles global keybindings and plugin-specific shortcuts.

-- 1. SETUP & IMPORTS
-- --------------------------------------------------------------------------
local map       = vim.keymap.set
local opts      = { noremap = true, silent = true }
local Keys      = {}

-- Load User Environment (safely)
local env_status, env = pcall(require, "config.user_env")
local env_config      = env_status and env.config or {}

-- ==========================================================================
-- 2. GENERAL KEYMAPS
-- ==========================================================================

-- Bad Habits (Disable Arrow Keys)
-- --------------------------------------------------------------------------
if env_config.bad_habbits then
    map({ "n", "i", "x", "v" }, "<Up>",    "<Nop>", opts)
    map({ "n", "i", "x", "v" }, "<Down>",  "<Nop>", opts)
    map({ "n", "i", "x", "v" }, "<Left>",  "<Nop>", opts)
    map({ "n", "i", "x", "v" }, "<Right>", "<Nop>", opts)
end

-- Insert Mode Navigation
-- --------------------------------------------------------------------------
map("i", "<C-h>", "<Left>",  opts)
map("i", "<C-l>", "<Right>", opts)
map("i", "<C-j>", "<Down>",  opts)
map("i", "<C-k>", "<Up>",    opts)

-- Window Management
-- --------------------------------------------------------------------------
-- Navigation
map("n", "<C-h>", "<C-w>h", { desc = "Window Left"  })
map("n", "<C-j>", "<C-w>j", { desc = "Window Down"  })
map("n", "<C-k>", "<C-w>k", { desc = "Window Up"    })
map("n", "<C-l>", "<C-w>l", { desc = "Window Right" })

-- Resizing
map("n", "<C-Up>",    ":resize +2<CR>",          opts)
map("n", "<C-Down>",  ":resize -2<CR>",          opts)
map("n", "<C-Left>",  ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Buffer Management
-- --------------------------------------------------------------------------
map("n", "<S-l>", ":bnext<CR>",     { desc = "Next Buffer" })
map("n", "<S-h>", ":bprevious<CR>", { desc = "Prev Buffer" })

-- Text Manipulation
-- --------------------------------------------------------------------------
-- Move Lines (Visual Mode)
map("v", "<A-j>", ":m .+1<CR>==",        opts)
map("v", "<A-k>", ":m .-2<CR>==",        opts)
map("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
map("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Indenting (Stay in Visual Mode)
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Standard Operations
-- --------------------------------------------------------------------------
map("n", "<leader>w",  "<cmd>w<cr>",   { desc = "Save File"               })
map("n", "<C-s>",      "<cmd>w<cr>",   { desc = "Save File"               })
map("n", "Q",          "<cmd>q!<cr>",  { desc = "Force Quit"              })
map("n", "<leader>nh", ":noh<CR>",     { desc = "Clear Search Highlights" })

-- Clipboard Operations
-- --------------------------------------------------------------------------
map("n", "x",          '"_x',          opts)                                -- Delete char without yanking
map("n", "<leader>y",  "ggVGy",        { desc = "Yank Whole File"     })
map("n", "Y",          "y$",           { desc = "Yank to end of line" })

-- Miscellaneous
-- --------------------------------------------------------------------------
map("i", "jk", "<Esc>",  { desc = "Fast Exit Insert" })
map("i", "qq", "<Esc>",  { desc = "Fast Exit Insert" })
map("i", "QQ", "<Esc>",  { desc = "Fast Exit Insert" })
map("n", "U",  "<C-r>",  { desc = "Redo"             }) -- Undo is 'u', Redo is 'U'

-- ==========================================================================
-- 3. PLUGIN SPECIFIC KEYMAPS
-- ==========================================================================

-- LuaSnip (Snippet Engine)
-- --------------------------------------------------------------------------
-- We do NOT require "luasnip" here. We require it inside the functions.

-- Jump to next placeholder
map({ "i", "s" }, "<A-j>", function()
    local ls = require("luasnip")
    if ls.jumpable(1) then ls.jump(1) end
end, opts)

-- Jump to prev placeholder
map({ "i", "s" }, "<A-k>", function()
    local ls = require("luasnip")
    if ls.jumpable(-1) then ls.jump(-1) end
end, opts)

-- Cycle through choice nodes
map({ "i", "s" }, "<A-l>", function()
    local ls = require("luasnip")
    if ls.choice_active() then ls.change_choice(1) end
end, opts)

map({ "i", "s" }, "<A-h>", function()
    local ls = require("luasnip")
    if ls.choice_active() then ls.change_choice(-1) end
end, opts)

-- Snacks.nvim (Telescope Replacement)
-- --------------------------------------------------------------------------
-- 1. Main Pickers
map("n", "<leader>fs", function() require("snacks").picker.smart() end,           { desc = "Smart Find Files"  })
map("n", "<leader>ff", function() require("snacks").picker.files() end,           { desc = "Find Files"        })
map("n", "<leader>fr", function() require("snacks").picker.recent() end,          { desc = "Recent Files"      })
map("n", "<leader>,",  function() require("snacks").picker.buffers() end,         { desc = "Buffers"           })
map("n", "<leader>:",  function() require("snacks").picker.command_history() end, { desc = "Command History"   })

-- Config Shortcut
map("n", "<leader>fc", function()
    require("snacks").picker.files({ cwd = vim.fn.stdpath("config") })
end, { desc = "Find Config" })

-- 2. Git Integration
map("n", "<leader>gl", function() require("snacks").picker.git_log() end,    { desc = "Git Log"    })
map("n", "<leader>gs", function() require("snacks").picker.git_status() end, { desc = "Git Status" })
map("n", "<leader>gd", function() require("snacks").picker.git_diff() end,   { desc = "Git Diff"   })

-- 3. Search & Grep
map("n", "<leader>sg", function() require("snacks").picker.grep() end,       { desc = "Grep Project"   })
map("n", "<leader>sb", function() require("snacks").picker.lines() end,      { desc = "Buffer Lines"   })
map("n", "<leader>sw", function() require("snacks").picker.grep_word() end,  { desc = "Grep Word"      })
map("x", "<leader>sw", function() require("snacks").picker.grep_word() end,  { desc = "Grep Selection" })

-- 4. LSP & Diagnostics
map("n", "gd",         function() require("snacks").picker.lsp_definitions() end,      { desc = "Goto Definition"           })
map("n", "gr",         function() require("snacks").picker.lsp_references() end,       { desc = "References", nowait = true })
map("n", "gI",         function() require("snacks").picker.lsp_implementations() end,  { desc = "Goto Implementation"       })
map("n", "gy",         function() require("snacks").picker.lsp_type_definitions() end, { desc = "Goto Type Def"             })
map("n", "<leader>ss", function() require("snacks").picker.lsp_symbols() end,          { desc = "LSP Symbols"               })
map("n", "<leader>sd", function() require("snacks").picker.diagnostics() end,          { desc = "Diagnostics"               })

-- 5. Meta
map("n", '<leader>s"', function() require("snacks").picker.registers() end,  { desc = "Registers"    })
map("n", "<leader>sh", function() require("snacks").picker.help() end,       { desc = "Help Pages"   })
map("n", "<leader>sk", function() require("snacks").picker.keymaps() end,    { desc = "Keymaps"      })
map("n", "<leader>su", function() require("snacks").picker.undo() end,       { desc = "Undo History" })
map("n", "<leader>sR", function() require("snacks").picker.resume() end,     { desc = "Resume Picker"})

-- Nvim-Tree (File Explorer)
-- --------------------------------------------------------------------------
-- NOTE: This function is exported to be used in NvimTree's 'on_attach' option
Keys.nvim_tree = function(bufnr)
    local api = require("nvim-tree.api")

    local function opt(desc)
        return { desc = "nvim-tree: " .. desc, buffer = bufnr, noremap = true, silent = true, nowait = true }
    end

    -- Navigation
    map("n", "<CR>",  api.node.open.edit,             opt("Open"                  ))
    map("n", "o",     api.node.open.edit,             opt("Open"                  ))
    map("n", "l",     api.node.open.edit,             opt("Open"                  ))
    map("n", "h",     api.node.navigate.parent_close, opt("Close Directory"       ))
    map("n", "<C-v>", api.node.open.vertical,         opt("Open: Vertical Split"  ))
    map("n", "<C-x>", api.node.open.horizontal,       opt("Open: Horizontal Split"))

    -- File Operations
    map("n", "a",     api.fs.create,                  opt("Create"            ))
    map("n", "d",     api.fs.remove,                  opt("Delete"            ))
    map("n", "r",     api.fs.rename,                  opt("Rename"            ))
    map("n", "y",     api.fs.copy.filename,           opt("Copy Name"         ))
    map("n", "Y",     api.fs.copy.relative_path,      opt("Copy Relative Path"))
    map("n", "gy",    api.fs.copy.absolute_path,      opt("Copy Absolute Path"))

    -- Tree Management
    map("n", "q",     api.tree.close,                 opt("Close"   ))
    map("n", "W",     api.tree.collapse_all,          opt("Collapse"))
    map("n", "S",     api.tree.search_node,           opt("Search"  ))
    map("n", "?",     api.tree.toggle_help,           opt("Help"    ))
    map("n", "<C-k>", api.node.show_info_popup,       opt("Info"    ))

    -- Custom Resizing
    map("n", ">",     function() vim.cmd("NvimTreeResize +10") end, opt("Expand Width"  ))
    map("n", "<",     function() vim.cmd("NvimTreeResize -10") end, opt("Collapse Width"))
end

-- CMP (Autocomplete)
-- --------------------------------------------------------------------------
-- NOTE: This function is used inside the cmp.setup() table in completion.lua
Keys.cmp = function(cmp, ls)
    return {
        -- 1. Escape Key: To get out of the completions menu
        ["<Esc>"] = cmp.mapping.abort(),

        -- 2. Enter Key: Confirm selection
        -- (select = false means you must manually highlight an item before pressing Enter)
        ["<CR>"]  = cmp.mapping.confirm({ select = false }),

        -- 3. Tab/Shift-Tab (Navigate > Expand > Jump)
        ["<Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_next_item()
            elseif ls.expand_or_jumpable() then
                ls.expand_or_jump()
            else
                fallback()
            end
        end, { "i", "s" }),

        ["<S-Tab>"] = cmp.mapping(function(fallback)
            if cmp.visible() then
                cmp.select_prev_item()
            elseif ls.jumpable(-1) then
                ls.jump(-1)
            else
                fallback()
            end
        end, { "i", "s" }),
    }
end

-- ==========================================================================
-- 4. COMMANDS & ABBREVIATIONS
-- ==========================================================================

-- CMD Abbreviations (Fix typos, quick commands)
vim.cmd([[cnoreab cls Cls]])
vim.cmd([[cnoreab W w]])
vim.cmd([[cnoreab W! w!]])

-- Insert Mode Abbreviations
vim.cmd([[inoreab idate <C-R>=strftime("%b %d %Y %H:%M")<CR>]])

-- Function Keys (Timestamp insertion)
map("n", "<F1>", 'oThis file was created on <C-R>=strftime("%b %d %Y %H:%M")<CR><ESC>', opts)
map("i", "<F1>", 'This file was created on <C-R>=strftime("%b %d %Y %H:%M")<CR><ESC>',  opts)

return Keys
