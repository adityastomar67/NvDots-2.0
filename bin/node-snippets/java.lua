-- ==========================================================================
-- JAVA SNIPPETS
-- ==========================================================================
-- lua/snippets/java.lua
-- Advanced Java snippets including dynamic Javadoc generation.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    java = {
        -- ======================================================================
        -- METHOD GENERATOR
        -- ======================================================================
        -- Generates a method with Visibility, Return Type, and smart Javadocs.
        ns.snippet("fn", {
            -- 1. Javadoc (Dynamic)
            -- Automatically updates based on Return Type (2), Args (4), and Throws (5)
            ns.dynamic_node(6, utils.jdocsnip, { 2, 4, 5 }),
            ns.text_node({ "", "" }),

            -- 2. Visibility
            ns.choice_node(1, {
                ns.text_node("public "),
                ns.text_node("private "),
            }),

            -- 3. Return Type
            ns.choice_node(2, {
                ns.text_node("void"),
                ns.text_node("String"),
                ns.text_node("char"),
                ns.text_node("int"),
                ns.text_node("double"),
                ns.text_node("boolean"),
                ns.insert_node(nil, ""),        -- Custom Type
            }),

            ns.text_node(" "),

            -- 4. Method Name
            ns.insert_node(3, "myFunc"),

            -- 5. Arguments
            ns.text_node("("),
            ns.insert_node(4),
            ns.text_node(")"),

            -- 6. Exceptions (Optional)
            ns.choice_node(5, {
                ns.text_node(""),               -- Option 1: None
                ns.snip_node(nil, {             -- Option 2: throws Exception
                    ns.text_node({ "", " throws " }),
                    ns.insert_node(1),
                }),
            }),

            -- 7. Body
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),
    }
}
