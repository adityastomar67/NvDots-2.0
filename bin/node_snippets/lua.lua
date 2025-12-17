-- ==========================================================================
-- LUA SNIPPETS CONFIGURATION
-- ==========================================================================
-- lua/snippets/lua.lua

-- Imports & Aliases
local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

-- ==========================================================================
-- SNIPPET DEFINITIONS
-- ==========================================================================

return {
    -- ======================================================================
    -- 1. DEBUGGING / PRINTING
    -- ======================================================================
    ns.snippet("lua print var", {
        ns.text_node("print(\""),
        ns.insert_node(1, "desrc"),
        ns.text_node(": \" .. "),
        ns.insert_node(2, "the_variable"),
        ns.text_node(")"),
    }),

    -- ======================================================================
    -- 2. FUNCTION DEFINITIONS
    -- ======================================================================

    -- TODO: Convert logic to Lua (Currently acts as a Java-style class placeholder)
    ns.snippet("fndef", {
        ns.dynamic_node(6, utils.luadocsnip, { 2, 4, 5 }),
        ns.text_node({ "", "" }),
        
        -- Visibility
        ns.choice_node(1, {
            ns.text_node("public "),
            ns.text_node("private "),
        }),
        
        -- Return Type
        ns.choice_node(2, {
            ns.text_node("void"),
            ns.text_node("String"),
            ns.text_node("char"),
            ns.text_node("int"),
            ns.text_node("double"),
            ns.text_node("boolean"),
            ns.insert_node(nil, ""),
        }),
        
        ns.text_node(" "),
        ns.insert_node(3, "myFunc"),
        ns.text_node("("),
        ns.insert_node(4),
        ns.text_node(")"),
        
        -- Throws/Extras
        ns.choice_node(5, {
            ns.text_node(""),
            ns.snip_node(nil, {
                ns.text_node({ "", " throws " }),
                ns.insert_node(1),
            }),
        }),
        
        ns.text_node({ " {", "\t" }),
        ns.insert_node(0),
        ns.text_node({ "", "}" }),
    }),

    -- Basic Local Function
    ns.snippet("fn basic", {
        ns.text_node("-- @param: "),
        ns.func_node(utils.copy, 2),
        ns.text_node({ "", "local " }),
        ns.insert_node(1), -- Function Name
        ns.text_node(" = function("),
        ns.insert_node(2, "fn param"),
        ns.text_node({ ")", "\t" }),
        ns.insert_node(0),
        ns.text_node({ "", "end" }),
    }),

    -- Module Function
    ns.snippet("fn module", {
        ns.text_node("-- @param: "),
        ns.func_node(utils.copy, 3),
        ns.text_node({ "", "" }),
        ns.insert_node(1, "modname"),
        ns.text_node("."),
        ns.insert_node(2, "fnname"),
        ns.text_node(" = function("),
        ns.insert_node(3, "fn param"),
        ns.text_node({ ")", "\t" }),
        ns.insert_node(0),
        ns.text_node({ "", "end" }),
    }),

    -- ======================================================================
    -- 3. CONDITIONALS
    -- ======================================================================

    -- Basic If
    ns.snippet({ trig = "basic if", wordTrig = true }, {
        ns.text_node({ "if " }),
        ns.insert_node(1),
        ns.text_node({ " then", "\t" }),
        ns.insert_node(0),
        ns.text_node({ "", "end" })
    }),

    -- Else
    ns.snippet({ trig = "ee", wordTrig = true }, {
        ns.text_node({ "else", "\t" }),
        ns.insert_node(0),
    }),

    -- ======================================================================
    -- 4. LOOPS
    -- ======================================================================

    -- Generic For Loop (Pairs/Ipairs vs Numeric)
    ns.snippet("for", {
        ns.text_node("for "),
        ns.choice_node(1, {
            -- Choice 1: Pairs/Ipairs
            ns.snip_node(nil, {
                ns.insert_node(1, "k"),
                ns.text_node(", "),
                ns.insert_node(2, "v"),
                ns.text_node(" in "),
                ns.choice_node(3, {
                    ns.text_node("pairs"),
                    ns.text_node("ipairs")
                }),
                ns.text_node("("),
                ns.insert_node(4),
                ns.text_node(")"),
            }),
            -- Choice 2: Numeric (i = 1, x)
            ns.snip_node(nil, {
                ns.insert_node(1, "i"),
                ns.text_node(" = "),
                ns.insert_node(2),
                ns.text_node(", "),
                ns.insert_node(3),
            })
        }),
        ns.text_node({ " do", "\t" }),
        ns.insert_node(0),
        ns.text_node({ "", "end" })
    }),
}
