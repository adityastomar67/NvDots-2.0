-- ==========================================================================
-- PYTHON SNIPPETS
-- ==========================================================================
-- lua/snippets/python.lua
-- Advanced Python snippets with dynamic docstring generation and 
-- auto-assignment of __init__ arguments.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

-- ==========================================================================
-- 1. HELPER FUNCTIONS (Docstrings)
-- ==========================================================================

-- Generates the Argument section of a docstring
-- --------------------------------------------------------------------------
local function generic_pdoc(ilevel, args)
    local indent        = string.rep("\t", ilevel)
    local nodes         = { 
        ns.text_node({ "'''", indent }) 
    }
    
    -- Short & Long Description
    nodes[#nodes + 1]   = ns.insert_node(1, "Small Description.")
    nodes[#nodes + 1]   = ns.text_node({ "", "", indent })
    nodes[#nodes + 1]   = ns.insert_node(2, "Long Description")
    nodes[#nodes + 1]   = ns.text_node({ "", "", indent .. "Args:" })

    -- Parse arguments string (e.g., "a, b, c")
    local args_list     = vim.split(args[1][1], ",", true)
    
    if args[1][1] == "" then
        args_list = {}
    end

    -- Create a docstring line for each argument
    for idx, arg in pairs(args_list) do
        local trimmed   = vim.trim(arg)
        if trimmed ~= "" then
            nodes[#nodes + 1] = ns.text_node({ "", string.rep("\t", ilevel + 1) .. trimmed .. ": " })
            nodes[#nodes + 1] = ns.insert_node(idx + 2, "Description For " .. trimmed)
        end
    end

    return nodes, #args_list
end

-- Function Docstring Builder
-- --------------------------------------------------------------------------
local function pyfdoc(args, ostate)
    local nodes, a_len  = generic_pdoc(1, args)
    
    -- Returns Section
    nodes[#nodes + 1]   = ns.choice_node(a_len + 2 + 1, { 
        ns.text_node(""), 
        ns.text_node({ "", "", "\tReturns:" }) 
    })
    nodes[#nodes + 1]   = ns.insert_node(a_len + 2 + 2)

    -- Raises Section
    nodes[#nodes + 1]   = ns.choice_node(a_len + 2 + 3, { 
        ns.text_node(""), 
        ns.text_node({ "", "", "\tRaises:" }) 
    })
    nodes[#nodes + 1]   = ns.insert_node(a_len + 2 + 4)
    
    -- Close Docstring
    nodes[#nodes + 1]   = ns.text_node({ "", "\t'''", "\t" })
    
    local snip          = ns.snip_node(nil, nodes)
    snip.old_state      = ostate or {}
    return snip
end

-- Class Docstring Builder
-- --------------------------------------------------------------------------
local function pycdoc(args, ostate)
    local nodes, _      = generic_pdoc(2, args)
    nodes[#nodes + 1]   = ns.text_node({ "", "\t\t'''", "" })
    
    local snip          = ns.snip_node(nil, nodes)
    snip.old_state      = ostate or {}
    return snip
end

-- ==========================================================================
-- 2. SNIPPET DEFINITIONS
-- ==========================================================================

return {
    -- ======================================================================
    -- CLASS DEFINITION
    -- ======================================================================
    -- Auto-generates __init__, self.assignments, and docstrings based on args.
    ns.snippet({ trig = "cls", dscr = "Documented Class Structure" }, {
        ns.text_node("class "),
        ns.insert_node(1, "CLASS"),
        ns.text_node("("),
        ns.insert_node(2, ""), -- Parent Class
        ns.text_node({ "):", "\t" }),
        
        -- Init Constructor
        ns.text_node({ "def __init__(self," }),
        ns.insert_node(3), -- Arguments
        ns.text_node({ "):", "\t\t" }),

        -- Dynamic Docstring
        ns.dynamic_node(4, pycdoc, { 3 }, { user_args = { 2 } }),

        -- Dynamic Self Assignments (self.arg = arg)
        ns.func_node(function(args)
            if not args[1][1] or args[1][1] == "" then
                return { "" }
            end
            
            local arg_list = vim.split(args[1][1], ",", true)
            local results = {}
            
            for _, item in ipairs(arg_list) do
                local trimmed = vim.trim(item)
                if trimmed ~= "" then
                    table.insert(results, "\t\tself." .. trimmed .. " = " .. trimmed)
                end
            end
            
            return results
        end, { 3 }),

        ns.insert_node(0),
    }),

    -- ======================================================================
    -- FUNCTION DEFINITION
    -- ======================================================================
    -- Standard function definition with dynamic docstring.
    ns.snippet({ trig = "fn", dscr = "Documented Function Structure" }, {
        ns.text_node("def "),
        ns.insert_node(1, "function"),
        ns.text_node("("),
        ns.insert_node(2), -- Arguments
        ns.text_node({ "):", "\t" }),
        
        -- Dynamic Docstring
        ns.dynamic_node(3, pyfdoc, { 2 }, { user_args = { 1 } }),
    }),
}
