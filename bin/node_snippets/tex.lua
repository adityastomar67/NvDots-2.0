-- ==========================================================================
-- LATEX SNIPPETS
-- ==========================================================================
-- lua/snippets/tex.lua
-- Snippets for TeX/LaTeX editing, including recursive lists and math modes.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

-- ==========================================================================
-- 1. LOCAL FUNCTIONS
-- ==========================================================================

-- Recursive List Helper
-- --------------------------------------------------------------------------
-- Allows infinite expansion of list items.
local rec_ls
rec_ls = function()
    return ns.snip_node(nil, ns.choice_node(1, {
        -- Choice 1: Exit list (Empty)
        ns.text_node(""),
        -- Choice 2: New Item
        ns.snip_node(nil, {
            ns.text_node({ "", "\t\\item " }),
            ns.insert_node(1),
            ns.dynamic_node(2, rec_ls, {})
        }),
    }))
end

-- ==========================================================================
-- 2. SNIPPET DEFINITIONS
-- ==========================================================================

return {
    -- ======================================================================
    -- ENVIRONMENTS
    -- ======================================================================

    -- Recursive Itemize
    ns.snippet("ls", {
        ns.text_node({ "\\begin{itemize}", "\t\\item " }),
        ns.insert_node(1),
        ns.dynamic_node(2, rec_ls, {}),
        ns.text_node({ "", "\\end{itemize}" }),
    }),

    -- Generic Environment (beg)
    -- \begin{env} ... \end{env}
    ns.ls.parser.parse_snippet(
        { trig = "beg" },
        "\\begin{${1:env}}\n\t$2\n\\end{$1}"
    ),

    -- Equation (beq)
    ns.ls.parser.parse_snippet(
        { trig = "beq" },
        "\\begin{equation*}\n\t$1\n\\end{equation*}"
    ),

    -- Aligned (bal)
    ns.ls.parser.parse_snippet(
        { trig = "bal" },
        "\\begin{aligned}\n\t$1\n\\end{aligned}"
    ),

    -- ======================================================================
    -- SECTIONS (REGEX)
    -- ======================================================================
    -- Triggers: "sec" -> \section, "ssec" -> \subsection, "sssec" -> \subsubsection
    ns.snippet({ trig = "(s*)sec", regTrig = true, wordTrig = true }, {
        ns.func_node(function(_, snip)
            return "\\" .. string.rep("sub", #snip.captures[1]) .. "section{"
        end, {}),
        ns.insert_node(1, "Title"),
        ns.text_node("}"),
        ns.insert_node(0),
    }),

    -- ======================================================================
    -- MATH & SYMBOLS
    -- ======================================================================

    -- Inline Math ($...$)
    ns.ls.parser.parse_snippet({ trig = "mk" }, "\\$$1\\$$0"),

    -- Fraction (\frac{}{})
    ns.ls.parser.parse_snippet({ trig = "fr" }, "\\frac{$1}{$2}"),

    -- Absolute Value (|...|)
    ns.ls.parser.parse_snippet({ trig = "abs" }, "\\|$1\\|"),

    -- Angled Brackets (<...>)
    ns.ls.parser.parse_snippet({ trig = "ab" }, "\\langle $1 \\rangle"),

    -- Arrows
    ns.ls.parser.parse_snippet({ trig = "lra" }, "\\leftrightarrow"),
    ns.ls.parser.parse_snippet({ trig = "Lra" }, "\\Leftrightarrow"),
    ns.ls.parser.parse_snippet({ trig = "to"  }, "\\to"),
    ns.ls.parser.parse_snippet({ trig = "To"  }, "\\Rightarrow"),
}
