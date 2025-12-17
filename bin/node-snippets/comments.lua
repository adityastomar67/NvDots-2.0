-- ==========================================================================
-- GLOBAL VISUAL SNIPPETS
-- ==========================================================================
-- lua/snippets/global.lua
-- Contains visual dividers and headers available in all filetypes.

local ns                                        = require("util.utils").node_snip

return {
    all = {
        -- ======================================================================
        -- 1. STATIC DIVIDER
        -- ======================================================================
        -- A fixed-width ASCII decoration box.
        ns.snippet("div 1", {
            ns.text_node({
                "----------------------",
                "---     "
            }),
            ns.insert_node(1, "title"),
            ns.text_node({
                "     ---",
                "-----[[------------]]-----",
            }),
        }),

        -- ======================================================================
        -- 2. DYNAMIC EXPANDING HEADER
        -- ======================================================================
        -- The top and bottom borders automatically expand to match the length
        -- of the input text using a lambda function.
        ns.snippet("header 1", {
            -- Top Border
            ns.text_node("----------"),
            ns.lambda(ns.lambda._1:gsub(".", "-"), 1),
            ns.text_node({ "----------", "" }),

            -- Middle Line (Content)
            ns.text_node("---       "),
            ns.insert_node(1, "header title"),
            ns.text_node({ "       ---", "" }),

            -- Bottom Border
            ns.text_node("----------"),
            ns.lambda(ns.lambda._1:gsub(".", "-"), 1),
            ns.text_node({ "----------", "" }),
        }),

        -- ======================================================================
        -- 3. TODO: FIGLET HEADER (Concept)
        -- ======================================================================
        -- Idea: Use figlet to create mega huge headings.
        -- Implementation Plan:
        -- 1. Capture written text
        -- 2. Trigger on exit snippet
        -- 3. Pass text to system figlet command
        -- 4. Convert output string to table
        -- 5. Calculate longest string
        -- 6. Generate frame based on length
    }
}
