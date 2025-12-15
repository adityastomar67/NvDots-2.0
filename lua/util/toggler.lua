-- ==========================================================================
-- TOGGLER MODULE
-- ==========================================================================
-- lua/core/toggler.lua
-- A smart utility to toggle words (true <-> false, yes <-> no) based on
-- global defaults or filetype-specific rules. Preserves casing.

local Toggler                                         = {}

-- ==========================================================================
-- 1. HELPER FUNCTIONS
-- ==========================================================================

-- Create Lookup Table
-- --------------------------------------------------------------------------
-- Creates a bidirectional map (key->val and val->key) without using the
-- deprecated 'vim.tbl_add_reverse_lookup'.
local function create_lookup(tbl)
    local new_tbl                               = vim.deepcopy(tbl)
    for k, v in pairs(tbl) do
        new_tbl[v]                              = k
    end
    return new_tbl
end

-- Preserve Case
-- --------------------------------------------------------------------------
-- Matches the casing of the replacement word to the original word.
-- Examples: "true" -> "false", "TRUE" -> "FALSE", "True" -> "False"
local function match_case(word, replacement)
    if not replacement then return word end

    if word == word:upper() then
        return replacement:upper()
    elseif word == word:sub(1, 1):upper() .. word:sub(2):lower() then
        return replacement:sub(1, 1):upper() .. replacement:sub(2):lower()
    end

    return replacement
end

-- ==========================================================================
-- 2. DEFAULT MAPPINGS
-- ==========================================================================

-- Global Defaults
-- --------------------------------------------------------------------------
-- These work in every filetype unless overridden.
local global_map                                = {
    ["true"]                                    = "false" ,
    ["yes"]                                     = "no"    ,
    ["on"]                                      = "off"   ,
    ["left"]                                    = "right" ,
    ["up"]                                      = "down"  ,
    ["high"]                                    = "low"   ,
    ["in"]                                      = "out"   ,
    ["start"]                                   = "end"   ,
    ["min"]                                     = "max"   ,
    ["before"]                                  = "after" ,
}

-- Filetype Defaults
-- --------------------------------------------------------------------------
-- Language-specific keywords.
local ft_map                                    = {
    python                                      = {
        ["None"]                                = "Some"   ,
        ["is"]                                  = "is not" ,
        ["if"]                                  = "else"   ,
    },
    lua                                         = {
        ["nil"]                                 = "non-nil" ,
        ["=="]                                  = "~="      ,
    },
    javascript                                  = {
        ["null"]                                = "undefined" ,
        ["const"]                               = "let"       ,
        ["==="]                                 = "!=="       ,
    },
    java                                        = {
        ["null"]                                = "non-null" ,
    },
    rust                                        = {
        ["Some"]                                = "None" ,
        ["Ok"]                                  = "Err"  ,
    },
}

-- Internal lookup tables (populated in setup)
local t_global                                  = create_lookup(global_map)
local t_ft                                      = {}

-- ==========================================================================
-- 3. SETUP FUNCTION
-- ==========================================================================

Toggler.setup = function(user_config)
    -- Merge user globals
    if user_config and user_config.globals then
        local user_globals                      = create_lookup(user_config.globals)
        t_global                                = vim.tbl_extend("force", t_global, user_globals)
    end

    -- Merge user filetypes
    if user_config and user_config.filetypes then
        for ft, maps in pairs(user_config.filetypes) do
            ft_map[ft]                          = vim.tbl_extend("force", ft_map[ft] or {}, maps)
        end
    end

    -- Process all filetype maps into bidirectional lookups
    for ft, maps in pairs(ft_map) do
        t_ft[ft]                                = create_lookup(maps)
    end
end

-- ==========================================================================
-- 4. MAIN TOGGLE LOGIC
-- ==========================================================================

Toggler.toggle = function()
    local mode                                  = vim.api.nvim_get_mode().mode
    local word                                  = ""

    -- 1. Capture the word
    -- ----------------------------------------------------------------------
    if mode == "v" or mode == "V" then
        -- Visual Mode: Yank selection to register 'v'
        vim.cmd('noautocmd normal! "vy')
        word                                    = vim.fn.getreg("v")
    else
        -- Normal Mode: Get word under cursor
        word                                    = vim.fn.expand("<cword>")
    end

    local clean_word                            = vim.trim(word)
    local filetype                              = vim.bo.filetype
    local result                                = nil

    -- 2. Find Match (Filetype Specific -> Global)
    -- ----------------------------------------------------------------------
    if t_ft[filetype] then
        result                                  = t_ft[filetype][clean_word] or t_ft[filetype][clean_word:lower()]
    end

    if not result then
        result                                  = t_global[clean_word] or t_global[clean_word:lower()]
    end

    -- 3. Validate and Notify
    -- ----------------------------------------------------------------------
    if not result then
        vim.notify("Toggler: '" .. clean_word .. "' is not supported.", vim.log.levels.WARN)
        return
    end

    -- 4. Apply Replacement
    -- ----------------------------------------------------------------------
    local new_word                              = match_case(clean_word, result)

    if mode == "v" or mode == "V" then
        -- Visual: Paste over selection
        vim.cmd("norm! gvc" .. new_word)
    else
        -- Normal: Change inner word
        vim.cmd("norm! ciw" .. new_word)
    end
end

return Toggler
