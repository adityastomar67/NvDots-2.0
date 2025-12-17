-- ==========================================================================
-- SHARED SNIPPETS CONFIGURATION
-- ==========================================================================
-- lua/snippets/all.lua
-- Defines snippets available in "all" filetypes (global snippets).

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

-- ==========================================================================
-- 1. LOCAL FUNCTIONS
-- ==========================================================================

-- Recursive List Snippet
-- --------------------------------------------------------------------------
-- A self-referencing function that creates an infinite list of items.
-- When expanded, it offers a choice:
-- 1. Stop (empty string)
-- 2. Continue (add a new item and recurse)
local rec_ls
rec_ls = function()
    return ns.snip_node(
        nil,
        ns.choice_node(1, {
            -- Choice 1: Stop recursion (Empty)
            -- Note: Must be first to avoid infinite loop during expansion
            ns.text_node(""),

            -- Choice 2: Add Item & Recurse
            ns.snip_node(nil, {
                ns.text_node({ "", "\t\\item " }),      -- Bullet/Item syntax
                ns.insert_node(1),                      -- User input
                ns.dynamic_node(2, rec_ls, {})          -- Call self
            }),
        })
    )
end

-- ==========================================================================
-- 2. SNIPPET DEFINITIONS
-- ==========================================================================

return {
    -- Dynamic Interpolation
    -- ----------------------------------------------------------------------
    -- Uses a dynamic_node to feed the output of a Lua function (date_input) into the placeholder text.
    ns.snippet("novel", {
        ns.text_node("It was a dark and stormy night on "),
        ns.dynamic_node(1, utils.date_input, {}, {
            user_args = { "%A, %B %d of %Y" }
        }),
        ns.text_node(" and the clocks were striking thirteen."),
    }),

    -- Auto-Pairs
    -- ----------------------------------------------------------------------
    -- Automatically closes brackets and quotes.
    -- Note: Assumes 'neg', 'char_count_same', etc., are defined in scope.
    utils.pair("(" , ")" , neg , char_count_same),
    utils.pair("{" , "}" , neg , char_count_same),
    utils.pair("[" , "]" , neg , char_count_same),
    utils.pair("<" , ">" , neg , char_count_same),
    utils.pair("'" , "'" , neg , even_count),
    utils.pair('"' , '"' , neg , even_count),
    utils.pair("`" , "`" , neg , even_count),

    -- System Commands
    -- ----------------------------------------------------------------------
    -- Executes a shell command (ls) and inserts the output.
    ns.snippet("bash", ns.func_node(utils.bash, {}, "ls")),

    -- Date & Time
    -- ----------------------------------------------------------------------
    -- Inserts the current date in YYYY-MM-DD format.
    ns.snippet({
        trig    = "ymd",
        name    = "Current date",
        dscr    = "Insert the current date"
    }, {
        ns.partial(os.date, "%Y-%m-%d"),
    }),

    -- Formatting Blocks
    -- ----------------------------------------------------------------------
    -- Quick block expansion triggered by "{,".
    ns.snippet({
        trig        = "{,",
        wordTrig    = false,
        hidden      = true
    }, {
        ns.text_node({ "{", "\t" }),
        ns.insert_node(1),
        ns.text_node({ "", "}" })
    }),

    -- Parsed Snippets (VSCode Style)
    -- ----------------------------------------------------------------------
    -- Standard Bash if-statement using the shorthand parse syntax.
    ns.ls.parser.parse_snippet(
        { trig = "tr" },
        "if ${1:[[ ${2:word} -eq ${3:word2} ]]}; then\n\t$4\nfi"
    ),
}
