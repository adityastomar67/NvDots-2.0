-- ==========================================================================
-- JAVA / C-LIKE SNIPPETS
-- ==========================================================================
-- lua/snippets/c.lua

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    c = {
        -- ======================================================================
        -- 1. GENERIC FUNCTION WITH PARAMETER MIRRORING
        -- ======================================================================
        ns.snippet("all fn", {
            -- Comment Parameters
            ns.text_node("//Parameters: "),
            
            -- Mirror Input: Copies text from Insert Node (2) to here
            ns.func_node(utils.copy, 2),
            
            -- Function Declaration
            ns.text_node({ "", "function " }),
            ns.insert_node(1),                  -- Function Name
            ns.text_node("("),
            ns.insert_node(2, "int foo"),       -- Parameters
            ns.text_node({ ") {", "\t" }),
            
            -- Body
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- ======================================================================
        -- 2. CLASS DEFINITION
        -- ======================================================================
        ns.snippet("class", {
            -- Visibility Choice
            ns.choice_node(1, {
                ns.text_node("public "),
                ns.text_node("private "),
            }),
            
            ns.text_node("class "),
            ns.insert_node(2),                  -- Class Name
            ns.text_node(" "),
            
            -- Inheritance Choice
            ns.choice_node(3, {
                ns.text_node("{"),              -- 1. No inheritance
                
                -- 2. Extends
                ns.snip_node(nil, {
                    ns.text_node("extends "),
                    ns.insert_node(1),
                    ns.text_node(" {"),
                }),
                
                -- 3. Implements
                ns.snip_node(nil, {
                    ns.text_node("implements "),
                    ns.insert_node(1),
                    ns.text_node(" {"),
                }),
            }),
            
            ns.text_node({ "", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}"  }),
        }),

        -- ======================================================================
        -- 3. ADVANCED METHOD GENERATOR (Java)
        -- ======================================================================
        ns.snippet({ trig = "fn" }, {
            -- Javadoc Generation (Dynamic)
            -- Takes inputs from nodes 2 (Type), 4 (Args), 5 (Throws)
            ns.dynamic_node(6, utils.jdocsnip, { 2, 4, 5 }),
            ns.text_node({ "", "" }),

            -- Visibility
            ns.choice_node(1, {
                ns.text_node({ "public "  }),
                ns.text_node({ "private " })
            }),

            -- Return Type
            ns.choice_node(2, {
                ns.text_node({ "void"    }),
                ns.insert_node(nil, { "" }),    -- Custom type
                ns.text_node({ "String"  }),
                ns.text_node({ "char".   }),
                ns.text_node({ "int".    }),
                ns.text_node({ "double"  }),
                ns.text_node({ "boolean" }),
            }),
            ns.text_node({ " " }),

            -- Method Name & Args
            ns.insert_node(3, { "myFunc" }),
            ns.text_node({ "(" }),
            ns.insert_node(4),
            ns.text_node({ ")" }),

            -- Exceptions Choice
            ns.choice_node(5, {
                ns.text_node({ "" }),
                ns.snip_node(nil, {
                    ns.text_node({ "", " throws " }),
                    ns.insert_node(1)
                })
            }),

            -- Body
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" })
        }),

        -- ======================================================================
        -- 4. PREPROCESSOR DIRECTIVE
        -- ======================================================================
        ns.snippet("#if", {
            ns.text_node("#if "),
            ns.insert_node(1, "1"),
            ns.text_node({ "", "" }),
            ns.insert_node(0),
            ns.text_node({ "", "#endif // " }),
            -- Mirrors the condition logic from node 1
            ns.func_node(function(args) return args[1] end, 1),
        }),
    }
}
