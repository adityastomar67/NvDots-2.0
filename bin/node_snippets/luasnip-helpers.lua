-- ==========================================================================
-- LUASNIP META-SNIPPETS
-- ==========================================================================
-- lua/snippets/lua_snippets.lua
-- These snippets are used to write OTHER snippets faster.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

return {
    -- ======================================================================
    -- 1. SNIPPET DEFINITION
    -- ======================================================================
    -- Trigger: 'snip' -> Generates a full ns.snippet block
    ns.snippet("snip", {
        ns.text_node("ns.snippet(\""),
        ns.insert_node(1, "trigger"),
        ns.text_node({ "\", {", "\t" }),
        ns.insert_node(0, "nodes"),
        ns.text_node({ "", "})," }),
    }),

    -- ======================================================================
    -- 2. TEXT NODES
    -- ======================================================================
    -- Trigger: 'tnode' -> Offers a choice between simple, newline-before, etc.
    ns.snippet("tnode", ns.choice_node(1, {
        -- Simple: ns.text_node("text")
        ns.snip_node(nil, {
            ns.text_node("ns.text_node(\""),
            ns.insert_node(1, "text"),
            ns.text_node("\"), "),
        }),
        -- Newline Before: ns.text_node({ "", "text" })
        ns.snip_node(nil, {
            ns.text_node("ns.text_node({ \"\", \""),
            ns.insert_node(1, "text"),
            ns.text_node("\" }), "),
        }),
        -- Newline After: ns.text_node({ "text", "" })
        ns.snip_node(nil, {
            ns.text_node("ns.text_node({ \""),
            ns.insert_node(1, "text"),
            ns.text_node("\", \"\" }), "),
        }),
        -- Both: ns.text_node({ "", "text", "" })
        ns.snip_node(nil, {
            ns.text_node("ns.text_node({ \"\", \""),
            ns.insert_node(1, "text"),
            ns.text_node("\", \"\" }), "),
        }),
    })),

    -- ======================================================================
    -- 3. INSERT NODES
    -- ======================================================================
    -- Trigger: 'inode' -> ns.insert_node(1, "default")
    ns.snippet("inode", {
        ns.text_node("ns.insert_node("),
        ns.insert_node(1, "1"),
        ns.text_node(", \""),
        ns.insert_node(2, "default_text"),
        ns.text_node("\"), "),
    }),

    -- ======================================================================
    -- 4. FUNCTION NODES
    -- ======================================================================
    -- Trigger: 'fnode' -> ns.func_node(fn, args)
    ns.snippet("fnode", {
        ns.text_node("ns.func_node(function(args, snip) return "),
        ns.insert_node(1, "args[1][1]"),
        ns.text_node(" end, { "),
        ns.insert_node(2, "1"),
        ns.text_node(" }), "),
    }),

    -- ======================================================================
    -- 5. CHOICE NODES
    -- ======================================================================
    -- Trigger: 'cnode' -> ns.choice_node(1, { ... })
    ns.snippet("cnode", {
        ns.text_node("ns.choice_node("),
        ns.insert_node(1, "1"),
        ns.text_node({ ", {", "\t" }),
        ns.text_node("ns.text_node(\""), ns.insert_node(2, "Choice 1"), ns.text_node({ "\"),", "\t" }),
        ns.text_node("ns.text_node(\""), ns.insert_node(3, "Choice 2"), ns.text_node("\"),"),
        ns.text_node({ "", "}), " }),
    }),

    -- ======================================================================
    -- 6. DYNAMIC NODES
    -- ======================================================================
    -- Trigger: 'dnode' -> ns.dynamic_node(1, func, args)
    ns.snippet("dnode", {
        ns.text_node("ns.dynamic_node("),
        ns.insert_node(1, "1"),
        ns.text_node(", "),
        ns.insert_node(2, "func_name"),
        ns.text_node(", { "),
        ns.insert_node(3, "args"),
        ns.text_node(" }), "),
    }),

    -- ======================================================================
    -- 7. RESTORE & REPEAT NODES
    -- ======================================================================
    -- Trigger: 'rnode' -> ns.restore_node(1) (or rep)
    ns.snippet("rnode", {
        ns.text_node("ns.rep("),
        ns.insert_node(1, "1"),
        ns.text_node("), "),
    }),

    -- ======================================================================
    -- 8. FORMAT NODES (fmt)
    -- ======================================================================
    -- Trigger: 'fmt' -> ns.fmt("string", { ... })
    ns.snippet("fmt", {
        ns.text_node("ns.fmt(\""),
        ns.insert_node(1, "format {} string"),
        ns.text_node("\", { "),
        ns.insert_node(2, "nodes"),
        ns.text_node(" }), "),
    }),
}
