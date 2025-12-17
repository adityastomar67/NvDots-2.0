-- ==========================================================================
-- HELP / DOCUMENTATION SNIPPETS
-- ==========================================================================
-- lua/snippets/help.lua
-- Snippets used for help files, vimdoc, or markdown formatting.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

return {
    -- ======================================================================
    -- 1. DYNAMIC TABLE OF CONTENTS LINE
    -- ======================================================================
    -- Creates a line connecting two points with dots, filling up to 80 chars.
    -- Example: Left Side .................................... |Right Side|
    ns.snippet({ trig = "con", wordTrig = true }, {
        ns.insert_node(1),
        
        -- Dynamic Dots Generator
        ns.func_node(function(args)
            -- Calculate padding: 80 - (len(left) + len(right) + spacers)
            local len_left  = #args[1][1]
            local len_right = #args[2][1]
            local spacer    = 4 -- Account for spaces and pipes
            local count     = 80 - (len_left + len_right + spacer)
            
            -- Guard against negative count
            if count < 0 then count = 0 end
            
            return { " " .. string.rep(".", count) .. " " }
        end, { 1, 2 }),
        
        ns.text_node({ "|" }),
        ns.insert_node(2),
        ns.text_node({ "|" }),
        ns.insert_node(0)
    }),

    -- ======================================================================
    -- 2. AUTO-BOLD / EMPHASIS
    -- ======================================================================
    -- Wraps text in asterisks (e.g., *bold*).
    -- Includes a condition to check for balanced pairs or existing asterisks.
    ns.snippet({ trig = "*", wordTrig = true }, {
        ns.text_node({ "*" }),
        ns.insert_node(1),
        ns.text_node({ "*" }),
        ns.insert_node(0)
    }, {
        -- Condition: Negate even count (ensure we aren't already inside one)
        cond = utils.part(neg, even_count, '%*')
    }),
}
