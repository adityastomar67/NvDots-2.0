-- ==========================================================================
-- TOGGLER MODULE (Pro Version)
-- ==========================================================================
-- lua/core/toggler.lua
-- A high-performance utility to toggle boolean/semantic words.
-- Features: Case preservation, register hygiene, and cursor anchoring.

local M = {}

-- ==========================================================================
-- 1. CONFIGURATION & DATA
-- ==========================================================================

-- Default Configuration
local config = {
    keymap = "<leader>t", -- Set to false to disable default mapping
    debug  = false,       -- Set true to see warnings when words don't match
}

-- Global Defaults (Bi-directional pairs)
local global_map = {
    ["true"]   = "false", ["yes"]    = "no",
    ["on"]     = "off",   ["left"]   = "right",
    ["up"]     = "down",  ["high"]   = "low",
    ["in"]     = "out",   ["start"]  = "end",
    ["min"]    = "max",   ["before"] = "after",
    ["width"]  = "height",["first"]  = "last",
    ["show"]   = "hide",  ["open"]   = "close",
}

-- Filetype Specific Defaults
local ft_map = {
    python     = { ["None"] = "Some", ["is"] = "is not", ["if"] = "else" },
    lua        = { ["nil"] = "non-nil", ["=="] = "~=", ["local"] = "global" },
    javascript = { ["null"] = "undefined", ["const"] = "let", ["==="] = "!==" },
    typescript = { ["null"] = "undefined", ["const"] = "let", ["==="] = "!==" },
    java       = { ["null"] = "non-null", ["private"] = "public" },
    rust       = { ["Some"] = "None", ["Ok"] = "Err" },
    go         = { ["true"] = "false", ["nil"] = "non-nil" },
}

-- Cache for compiled lookups
local lookup_cache = {
    global = nil,
    ft = {},
}

-- ==========================================================================
-- 2. HELPER FUNCTIONS
-- ==========================================================================

---Creates a bidirectional lookup table (key <-> value)
---@param tbl table<string, string>
---@return table<string, string>
local function create_bidirectional_lookup(tbl)
    local new_tbl = {}
    for k, v in pairs(tbl) do
        new_tbl[k] = v
        new_tbl[v] = k
    end
    return new_tbl
end

---Matches the casing of the original word
---@param word string Original word found in buffer
---@param replacement string The candidate replacement
---@return string
local function match_case(word, replacement)
    if not replacement then return word end

    -- All UPPERCASE (TRUE -> FALSE)
    if word == word:upper() then
        return replacement:upper()
    end

    -- Title Case (True -> False)
    -- We check if the first char is upper and the second char (if exists) is lower
    if word:sub(1, 1) == word:sub(1, 1):upper() and (#word == 1 or word:sub(2, 2) == word:sub(2, 2):lower()) then
        return replacement:sub(1, 1):upper() .. replacement:sub(2):lower()
    end

    -- Default to lowercase (true -> false)
    return replacement:lower()
end

---Safely retrieves visual selection without clobbering user clipboard
---@return string
local function get_visual_selection()
    -- Save current register content and type
    local old_reg = vim.fn.getreg('"')
    local old_regtype = vim.fn.getregtype('"')

    -- Yank visual selection into unnamed register
    vim.cmd('noautocmd normal! "vy')
    local selection = vim.fn.getreg("v")

    -- Restore register
    vim.fn.setreg('"', old_reg, old_regtype)

    return selection
end

-- ==========================================================================
-- 3. CORE LOGIC
-- ==========================================================================

---Main toggle function
function M.toggle()
    local mode = vim.api.nvim_get_mode().mode
    local word = ""
    local is_visual = (mode == "v" or mode == "V")

    -- 1. Capture Target
    if is_visual then
        word = get_visual_selection()
    else
        word = vim.fn.expand("<cword>")
    end

    local clean_word = vim.trim(word)
    local filetype = vim.bo.filetype
    local replacement = nil

    -- 2. Initialize Lookups (Lazy Load)
    if not lookup_cache.global then
        lookup_cache.global = create_bidirectional_lookup(global_map)
    end
    if not lookup_cache.ft[filetype] and ft_map[filetype] then
        lookup_cache.ft[filetype] = create_bidirectional_lookup(ft_map[filetype])
    end

    -- 3. Find Match (Filetype > Global)
    -- Try exact match first, then lowercase match
    local ft_lookup = lookup_cache.ft[filetype]
    if ft_lookup then
        replacement = ft_lookup[clean_word] or ft_lookup[clean_word:lower()]
    end

    if not replacement then
        replacement = lookup_cache.global[clean_word] or lookup_cache.global[clean_word:lower()]
    end

    -- 4. Execute Replacement
    if not replacement then
        if config.debug then
            vim.notify("Toggler: No mapping for '" .. clean_word .. "'", vim.log.levels.INFO)
        end
        return
    end

    local final_word = match_case(clean_word, replacement)

    if is_visual then
        -- Visual Mode: Simple paste replacement
        vim.cmd("normal! gvc" .. final_word)
    else
        -- Normal Mode: 'ciw' logic with cursor preservation
        -- 'ciw' is preferred over Lua text-set because it preserves dot-repeat (.) capability

        local col = vim.fn.col(".")
        -- Execute change
        vim.cmd("normal! ciw" .. final_word)

        -- Attempt to restore cursor position to start of word implies we shouldn't move
        -- standard 'ciw' puts cursor at end of new word usually.
        -- We reset to the original column if possible.
        if #final_word < #clean_word then
             -- If new word is shorter, cursor might be valid, just ensure we didn't drift too far
             vim.fn.cursor(vim.fn.line("."), math.min(col, vim.fn.col("$") - 1))
        else
             -- If new word is longer, stick to original start column
             vim.fn.cursor(vim.fn.line("."), col)
        end
    end
end

-- ==========================================================================
-- 4. SETUP
-- ==========================================================================

---Setup function to initialize the module
---@param user_config? table
function M.setup(user_config)
    user_config = user_config or {}

    -- Merge Config
    if user_config.debug ~= nil then config.debug = user_config.debug end
    if user_config.keymap ~= nil then config.keymap = user_config.keymap end

    -- Merge Global Map
    if user_config.globals then
        global_map = vim.tbl_extend("force", global_map, user_config.globals)
        lookup_cache.global = nil -- Force rebuild
    end

    -- Merge Filetype Maps
    if user_config.filetypes then
        for ft, maps in pairs(user_config.filetypes) do
            ft_map[ft] = vim.tbl_extend("force", ft_map[ft] or {}, maps)
            lookup_cache.ft[ft] = nil -- Force rebuild
        end
    end

    -- Apply Keymap
    if config.keymap then
        vim.keymap.set({"n", "v"}, config.keymap, M.toggle, {
            desc = "Toggle Word (True/False)",
            silent = true
        })
    end
end

return M
