-- ==========================================================================
-- MARKDOWN SNIPPETS
-- ==========================================================================
-- lua/snippets/markdown.lua
-- Essential snippets for writing documentation, notes, and READMEs.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    markdown = {
        -- ======================================================================
        -- 1. FORMATTING
        -- ======================================================================
        
        -- Bold (**text**)
        ns.snippet({ trig = "**", wordTrig = false }, {
            ns.text_node("**"),
            ns.insert_node(1, "bold text"),
            ns.text_node("**"),
        }),

        -- Italic (*text*)
        ns.snippet({ trig = "*", wordTrig = false }, {
            ns.text_node("*"),
            ns.insert_node(1, "italic text"),
            ns.text_node("*"),
        }),

        -- Strikethrough (~~text~~)
        ns.snippet({ trig = "~~", wordTrig = false }, {
            ns.text_node("~~"),
            ns.insert_node(1, "strikethrough"),
            ns.text_node("~~"),
        }),

        -- Inline Code (`text`)
        ns.snippet({ trig = "`", wordTrig = false }, {
            ns.text_node("`"),
            ns.insert_node(1, "code"),
            ns.text_node("`"),
        }),

        -- ======================================================================
        -- 2. LINKS & IMAGES
        -- ======================================================================
        
        -- Link [text](url)
        ns.snippet("link", {
            ns.text_node("["),
            ns.insert_node(1, "text"),
            ns.text_node("]("),
            ns.insert_node(2, "url"),
            ns.text_node(")"),
        }),

        -- Image ![alt](url)
        ns.snippet("img", {
            ns.text_node("!["),
            ns.insert_node(1, "alt text"),
            ns.text_node("]("),
            ns.insert_node(2, "url"),
            ns.text_node(")"),
        }),

        -- Reference Link [text][ref]
        ns.snippet("ref", {
            ns.text_node("["),
            ns.insert_node(1, "text"),
            ns.text_node("]["),
            ns.insert_node(2, "id"),
            ns.text_node("]"),
        }),

        -- ======================================================================
        -- 3. BLOCKS & LISTS
        -- ======================================================================

        -- Code Block
        -- ```lang
        -- code
        -- ```
        ns.snippet("cb", {
            ns.text_node("```"),
            ns.insert_node(1, "lang"),
            ns.text_node({ "", "" }),
            ns.insert_node(0),
            ns.text_node({ "", "```" }),
        }),

        -- Checkbox List Item
        ns.snippet("todo", {
            ns.text_node("- [ ] "),
            ns.insert_node(0, "task"),
        }),

        -- Done List Item
        ns.snippet("done", {
            ns.text_node("- [x] "),
            ns.insert_node(0, "task"),
        }),

        -- ======================================================================
        -- 4. META / UTILS
        -- ======================================================================

        -- YAML Frontmatter (for static site generators)
        ns.snippet("meta", {
            ns.text_node({ "---", "title: " }),
            ns.insert_node(1, "Title"),
            ns.text_node({ "", "date: " }),
            ns.partial(os.date, "%Y-%m-%d"),
            ns.text_node({ "", "tags: [" }),
            ns.insert_node(2),
            ns.text_node({ "]", "---", "" }),
            ns.insert_node(0),
        }),
    }
}
