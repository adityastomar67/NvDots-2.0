-- NOTE: Some autocmds are not linked to any keymaps, Do that!!

-- ==========================================================================
-- KEYMAPPINGS CONFIGURATION
-- ==========================================================================
-- lua/config/keymaps.lua
-- This file handles global keybindings and plugin-specific shortcuts.
-- Shorten function name & common options
local map                = vim.keymap.set
local opts               = { noremap = true, silent = true }

-- ==========================================================================
-- 1. CUSTOM MODULES (Zen & Toggler)
-- ==========================================================================

-- Load User Environment
local env_status, env    = pcall(require, "config.user_env")
local env_config         = env_status and env.config or {}

-- Load Toggler (Custom module)
local status_ok, toggler = pcall(require, "util.toggler")
if status_ok then
    toggler.setup(env_config.toggles or {})
else
    vim.notify("util.toggler not found.", vim.log.levels.WARN)
end

-- Load Zen Mode
pcall(require, "util.zen")

-- ==========================================================================
-- 2. GENERAL KEYMAPS
-- ==========================================================================

-- Window Navigation
-- --------------------------------------------------------------------------
map("n" , "<C-h>"       , "<C-w>h"              , { desc = "Window Left"  })
map("n" , "<C-j>"       , "<C-w>j"              , { desc = "Window Down"  })
map("n" , "<C-k>"       , "<C-w>k"              , { desc = "Window Up"    })
map("n" , "<C-l>"       , "<C-w>l"              , { desc = "Window Right" })

-- Window Resizing
-- --------------------------------------------------------------------------
map("n" , "<C-Up>"      , ":resize +2<CR>"          , opts)
map("n" , "<C-Down>"    , ":resize -2<CR>"          , opts)
map("n" , "<C-Left>"    , ":vertical resize -2<CR>" , opts)
map("n" , "<C-Right>"   , ":vertical resize +2<CR>" , opts)

-- Buffer Navigation
-- --------------------------------------------------------------------------
map("n" , "<S-l>"       , ":bnext<CR>"          , { desc = "Next Buffer" })
map("n" , "<S-h>"       , ":bprevious<CR>"      , { desc = "Prev Buffer" })

-- Text Manipulation (Visual Mode)
-- --------------------------------------------------------------------------
map("v" , "<A-j>"       , ":m .+1<CR>=="        , opts)
map("v" , "<A-k>"       , ":m .-2<CR>=="        , opts)
map("x" , "<A-j>"       , ":move '>+1<CR>gv-gv" , opts)
map("x" , "<A-k>"       , ":move '<-2<CR>gv-gv" , opts)

-- Indenting
-- --------------------------------------------------------------------------
map("v" , "<"           , "<gv"                 , opts)
map("v" , ">"           , ">gv"                 , opts)

-- Standard Operations
-- --------------------------------------------------------------------------
map("n" , "<leader>w"   , "<cmd>w<cr>"          , { desc = "Save File"               })
map("n" , "<C-s>"       , "<cmd>w<cr>"          , { desc = "Save File"               })
map("n" , "Q"           , "<cmd>q!<cr>"         , { desc = "Force Quit"              })
map("n" , "<leader>nh"  , ":noh<CR>"            , { desc = "Clear Search Highlights" })

-- Copy/Paste Improvements
-- --------------------------------------------------------------------------
map("n" , "x"           , '"_x'                 , opts)
map("n" , "<leader>y"   , "ggVGy"               , { desc = "Yank Whole File"     })
map("n" , "Y"           , "y$"                  , { desc = "Yank to end of line" })

-- Miscellaneous
-- --------------------------------------------------------------------------
map("i" , "jk"          , "<Esc>"               , { desc = "Fast Exit Insert" })
map("i" , "qq"          , "<Esc>"               , { desc = "Fast Exit Insert" })
map("n" , "U"           , "<C-r>"               , { desc = "Redo"             })

-- ==========================================================================
-- 3. PLUGIN SPECIFIC KEYMAPS
-- ==========================================================================
-- LuaSnip (Snippet Completion)
-- 1. Safely try to load luasnip
local status_ok, ls = pcall(require, "luasnip")

-- 2. Guard Clause: If loading failed, stop execution here
if status_ok then
    -- 1. Expand & Jump
    map({ "i", "s" } , "<A-p>" , function()
        if ls.expand_or_jumpable() then ls.expand() end
    end, opts)

    map({ "i", "s" } , "<A-k>" , function()
        if ls.jumpable(1) then ls.jump(1) end
    end, opts)

    map({ "i", "s" } , "<A-j>" , function()
        if ls.jumpable(-1) then ls.jump(-1) end
    end, opts)

    -- 2. Cycle Choices
    -- Note: <C-E> and <A-l> perform similar actions, but <A-l> has an Easter Egg
    map({ "i", "s" } , "<C-E>" , function()
        if ls.choice_active() then ls.change_choice(1) end
    end, { silent = true })

    map({ "i", "s" } , "<A-l>" , function()
        if ls.choice_active() then
            ls.change_choice(1)
        else
            print(os.date("%H:%M:%S"))      -- Print current time if not in a snippet choice (Easter Egg)
        end
    end, opts)

    map({ "i", "s" } , "<A-h>" , function()
        if ls.choice_active() then ls.change_choice(-1) end
    end, opts)

    -- 3. Quick Break
    map({ "i", "s" } , "<A-y>" , "<Esc>o" , opts)
    end

-- Snacks (Modern Replacement for Telescope)
-- --------------------------------------------------------------------------
local snacks_ok, snacks = pcall(require, "snacks")
if snacks_ok then
    -- Top Pickers
    map("n" , "<leader>fs" , function() Snacks.picker.smart() end               , { desc = "Smart Find Files"          })
    map("n" , "<leader>,"  , function() Snacks.picker.buffers() end             , { desc = "Buffers"                   })
    map("n" , "<leader>/"  , function() Snacks.picker.grep() end                , { desc = "Grep"                      })
    map("n" , "<leader>:"  , function() Snacks.picker.command_history() end     , { desc = "Command History"           })

    -- Find Files
    map("n" , "<leader>ff" , function() Snacks.picker.files() end               , { desc = "Find Files"                })
    map("n" , "<leader>fr" , function() Snacks.picker.recent() end              , { desc = "Recent Files"              })
    map("n" , "<leader>fc" , function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Find Config" })

    -- Git
    map("n" , "<leader>gl" , function() Snacks.picker.git_log() end             , { desc = "Git Log"                   })
    map("n" , "<leader>gs" , function() Snacks.picker.git_status() end          , { desc = "Git Status"                })
    map("n" , "<leader>gd" , function() Snacks.picker.git_diff() end            , { desc = "Git Diff"                  })

    -- Grep / Search
    map("n" , "<leader>sb" , function() Snacks.picker.lines() end               , { desc = "Buffer Lines"              })
    map("n" , "<leader>sg" , function() Snacks.picker.grep() end                , { desc = "Grep"                      })
    map("n" , "<leader>sw" , function() Snacks.picker.grep_word() end           , { desc = "Grep Word"                 })
    map("x" , "<leader>sw" , function() Snacks.picker.grep_word() end           , { desc = "Grep Selection"            })
    map("n" , '<leader>s"' , function() Snacks.picker.registers() end           , { desc = "Registers"                 })
    map("n" , "<leader>sd" , function() Snacks.picker.diagnostics() end         , { desc = "Diagnostics"               })
    map("n" , "<leader>sh" , function() Snacks.picker.help() end                , { desc = "Help Pages"                })
    map("n" , "<leader>sk" , function() Snacks.picker.keymaps() end             , { desc = "Keymaps"                   })
    map("n" , "<leader>sR" , function() Snacks.picker.resume() end              , { desc = "Resume Picker"             })
    map("n" , "<leader>su" , function() Snacks.picker.undo() end                , { desc = "Undo History"              })

    -- LSP Pickers
    map("n" , "gd"         , function() Snacks.picker.lsp_definitions() end     , { desc = "Goto Definition"           })
    map("n" , "gr"         , function() Snacks.picker.lsp_references() end      , { desc = "References", nowait = true })
    map("n" , "gI"         , function() Snacks.picker.lsp_implementations() end , { desc = "Goto Implementation"       })
    map("n" , "gy"         , function() Snacks.picker.lsp_type_definitions() end, { desc = "Goto Type Def"             })
    map("n" , "<leader>ss" , function() Snacks.picker.lsp_symbols() end         , { desc = "LSP Symbols"               })
end

-- ==========================================================================
-- 4. UTILITIES / COMMANDS
-- ==========================================================================

-- Abbreviations
vim.cmd([[cnoreab cls Cls]])
vim.cmd([[cnoreab W w]])
vim.cmd([[cnoreab W! w!]])
vim.cmd([[inoreab idate <C-R>=strftime("%b %d %Y %H:%M")<CR>]])

-- Function Keys
map("n" , "<F1>"        , 'oThis file was created on <C-R>=strftime("%b %d %Y %H:%M")<CR><ESC>' , opts)
