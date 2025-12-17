-- ==========================================================================
-- NEORG SNIPPETS
-- ==========================================================================
-- lua/snippets/norg.lua
-- Snippets for the Neorg note-taking organization system.
-- Spec: https://github.com/nvim-neorg/neorg/blob/main/docs/NFF-0.1-spec.md

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    norg = {
        -- ======================================================================
        -- 1. BLOCKS & STRUCTURE
        -- ======================================================================

        -- Code Block (@code lang ... @end)
        ns.snippet("code", {
            ns.text_node("@code "),
            ns.insert_node(1, "lua"),
            ns.text_node({ "", "" }),
            ns.insert_node(0),
            ns.text_node({ "", "@end" }),
        }),

        -- Math Block (@math ... @end)
        ns.snippet("math", {
            ns.text_node({ "@math", "" }),
            ns.insert_node(1, "f(x) = y"),
            ns.text_node({ "", "@end" }),
        }),

        -- Comment Block (@comment ... @end)
        ns.snippet("comment", {
            ns.text_node({ "@comment", "" }),
            ns.insert_node(1, "text"),
            ns.text_node({ "", "@end" }),
        }),

        -- Table (@table ... @end)
        ns.snippet("tbl", {
            ns.text_node({ "@table", "" }),
            ns.insert_node(1, "Col 1"),
            ns.text_node(" | "),
            ns.insert_node(2, "Col 2"),
            ns.text_node({ "", "-" }),
            ns.text_node({ "", "" }),
            ns.insert_node(0),
            ns.text_node({ "", "@end" }),
        }),

        -- ======================================================================
        -- 2. LINKS & ANCHORS
        -- ======================================================================

        -- Standard Link {URL}[Text]
        ns.snippet("link", {
            ns.text_node("{"),
            ns.insert_node(1, "url"),
            ns.text_node("}["),
            ns.insert_node(2, "text"),
            ns.text_node("]"),
        }),

        -- Anchor Definition [Text]{URL} (Note: Neorg is flexible, usually {Target}[Text])
        ns.snippet("anchor", {
            ns.text_node("["),
            ns.insert_node(1, "text"),
            ns.text_node("]{"),
            ns.insert_node(2, "target"),
            ns.text_node("}"),
        }),

        -- File Link {:path/to/file:}
        ns.snippet("file", {
            ns.text_node("{:"),
            ns.insert_node(1, "path"),
            ns.text_node(":"),
            ns.insert_node(2), -- Optional section/line
            ns.text_node("}"),
        }),

        -- ======================================================================
        -- 3. TASKS & TODOS
        -- ======================================================================

        -- Undone Task
        ns.snippet("todo", {
            ns.text_node("- ( ) "),
            ns.insert_node(1, "task"),
        }),

        -- Done Task
        ns.snippet("done", {
            ns.text_node("- (x) "),
            ns.insert_node(1, "task"),
        }),

        -- Pending/Recurring Task
        ns.snippet("pend", {
            ns.text_node("- (-) "),
            ns.insert_node(1, "task"),
        }),

        -- ======================================================================
        -- 4. MEDIA (IMAGES & EMBEDS)
        -- ======================================================================

        -- Embed Image
        ns.snippet("image", {
            ns.text_node({ "@embed image", "" }),
            ns.insert_node(1, "path/to/image.png"),
            ns.text_node({ "", "@end" }),
        }),

        -- ======================================================================
        -- 5. GTD & METADATA
        -- ======================================================================

        -- Current Date (YYYY-MM-DD)
        ns.snippet("date", {
            ns.partial(os.date, "%Y-%m-%d"),
        }),

        -- Project Starter (GTD)
        ns.snippet("project", {
            ns.text_node("* "),
            ns.insert_node(1, "Project Name"),
            ns.text_node({ "", "\t" }),
            -- Metadata
            ns.text_node("  #context ")   , ns.insert_node(2, "@home"), ns.text_node({ "", "\t" }),
            ns.text_node("  #time.start "), ns.partial(os.date, "%Y-%m-%d"), ns.text_node({ "", "\t" }),
            ns.text_node("  #time.due ")  , ns.insert_node(3, "YYYY-MM-DD"), ns.text_node({ "", "" }),
            -- Initial Task
            ns.text_node("\t- ( ) "),
            ns.insert_node(0, "First Action"),
        }),

        -- Area of Focus
        ns.snippet("focus", {
            ns.text_node("| "),
            ns.insert_node(1, "Focus Area"),
            ns.text_node({ "", "" }),
            ns.insert_node(0),
            ns.text_node({ "", "| _" }),
        }),
    }
}
