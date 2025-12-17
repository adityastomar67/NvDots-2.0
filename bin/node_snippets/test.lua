-- ==========================================================================
-- GLOBAL / ALL SNIPPETS
-- ==========================================================================
-- lua/snippets/all.lua
-- Contains snippets available in every filetype, testing various LuaSnip features.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("util.utils")

-- ==========================================================================
-- 1. HELPER FUNCTIONS
-- ==========================================================================

-- Debug Condition Helper
-- Prints debug info when a snippet condition is checked
local co = function(cursline, trigmatch, captures)
    print("cursline: " .. cursline)
    print("trigmatch: " .. trigmatch)
    print(vim.inspect(captures))
    return true
end

-- Dynamic Line Generator
-- Creates 'count' number of input nodes based on the first argument
local function lines(args, snip, old_state, initial_text)
    local nodes = {}
    if not old_state then old_state = {} end

    -- Parse input number
    local count = tonumber(args[1][1])

    if count then
        for j = 1, count do
            local iNode
            -- Preserve text if user jumps back
            if old_state and old_state[j] then
                iNode = ns.insert_node(j, old_state[j].old_text)
            else
                iNode = ns.insert_node(j, initial_text)
            end
            
            nodes[2 * j - 1] = iNode
            nodes[2 * j]     = ns.text_node({ "", "" }) -- Linebreak
            old_state[j]     = iNode
        end
    else
        nodes[1] = ns.text_node("Enter a number!")
    end

    local snip_node = ns.snip_node(nil, nodes)
    snip_node.old_state = old_state
    return snip_node
end

-- ==========================================================================
-- 2. SNIPPET DEFINITIONS
-- ==========================================================================

return {
    -- ======================================================================
    -- BASICS
    -- ======================================================================
    
    -- Basic Trigger with Function Append
    ns.snippet("trig1", {
        ns.insert_node(1),
        ns.insert_node(2, { "first_line_of_second", "second_line_of_second" }),
        ns.func_node(function(args, snip, user_arg_1) 
            return args[2][1] .. user_arg_1 
        end, { 1, 2 }, "Will be appended to text from i(0)"),
        ns.insert_node(0)
    }),

    -- Indented Snippet Node
    ns.snippet("isn2", {
        ns.isn(1, ns.text_node({ "//This is", "A multiline", "comment" }), "$PARENT_INDENT//")
    }),

    -- Choice Node
    ns.snippet("trig", ns.choice_node(1, {
        ns.text_node("Ugh boring, a text node"),
        ns.insert_node(nil, "At least I can edit something now..."),
        ns.func_node(function(args) return "Still only counts as text!!" end, {})
    })),

    -- Dynamic Date Input
    ns.snippet("test dynamic", {
        ns.text_node("AAA "),
        ns.dynamic_node(1, utils.date_input, {}, { user_args = "%A, %B %d of %Y" }),
        ns.text_node(" BBB "),
        ns.insert_node(2, "second"),
        ns.text_node(". "),
    }),

    -- ======================================================================
    -- ADVANCED / REGEX / CALLBACKS
    -- ======================================================================

    -- Advanced Configuration Test
    ns.snippet({
        trig        = "testadvanced",
        name        = "test advanced snippet",
        dscr        = "testing all features of luasnip",
        wordTrig    = true,
        regTrig     = false,
        hidden      = false,
    }, {
        ns.func_node(function(args, snip, user_arg_1)
            if user_arg_1 ~= nil then
                return user_arg_1 .. args[1][1]
            end
        end, { 3, 2 }, "<<<<< "),
        ns.text_node({ "AAA ", "" }), ns.insert_node(1, "aaaaa"),
        ns.text_node({ "", "BBB", "" }), ns.insert_node(2, "bbbbb"),
        ns.text_node({ "", "CCC", "" }), ns.insert_node(3, "ccccc"),
        ns.func_node(function(args, snip, user_arg_1) 
            return args[1][1] .. user_arg_1 
        end, { 1 }, " >>>>"),
    }, {
        condition   = co,
        callbacks   = { [2] = { [events.enter] = function() print "2!" end } }
    }),

    -- Regex Capture
    ns.snippet({ trig = "b(%d)", regTrig = true },
        ns.func_node(function(args, snip)
            return "Captured Text: " .. snip.captures[1] .. "." 
        end, {})
    ),

    -- Dynamic Lines (uses helper function 'lines')
    ns.snippet("trig", {
        ns.insert_node(1, "1"),
        ns.dynamic_node(2, lines, { 1 }, { user_args = "Sample Text" })
    }),

    -- Conditional Regex (Even numbers only)
    ns.snippet({ trig = "c(%d+)", regTrig = true }, {
        ns.text_node("will only expand for even numbers"),
    }, {
        condition = function(line_to_cursor, matched_trigger, captures)
            return tonumber(captures[1]) % 2 == 0
        end,
    }),

    -- ======================================================================
    -- TRANSFORMATIONS & LAMBDAS
    -- ======================================================================

    -- String Transformations
    ns.snippet("transform", {
        ns.lambda(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
        ns.text_node({ "", "" }),
        ns.insert_node(1, "initial text"),
        ns.text_node({ "", "" }),
        ns.lambda(l._1:match("[^i]*$"):gsub("i", "o"):gsub(" ", "_"):upper(), 1),
    }),

    -- Dependent Transformations
    ns.snippet("transform2", {
        ns.insert_node(1, "initial text"),
        ns.text_node("::"),
        ns.insert_node(2, "replacement for e"),
        ns.text_node({ "", "" }),
        ns.lambda(l._1:gsub("e", l._2), { 1, 2 }),
    }),

    -- Regex Capture Transformation
    ns.snippet({ trig = "trafo(%d+)", regTrig = true }, {
        ns.lambda(l.CAPTURE1:gsub("1", l.TM_FILENAME), {}),
    }),

    -- ======================================================================
    -- UTILITY NODES (Repeat, Match, Partial)
    -- ======================================================================

    -- TM_SELECTED_TEXT (Hyperlink)
    ns.snippet("link_url", {
        ns.text_node('<a href="'),
        ns.func_node(function(_, snip) return snip.env.TM_SELECTED_TEXT[1] or {} end, {}),
        ns.text_node('">'), ns.insert_node(1), ns.text_node("</a>"), ns.insert_node(0),
    }),

    -- Repeat Node
    ns.snippet("repeat", { ns.insert_node(1, "text"), ns.text_node({ "", "" }), ns.rep(1) }),

    -- Partial (os.date)
    ns.snippet("part", ns.partial(os.date, "%Y")),

    -- Match Node 1 (Contains Number)
    ns.snippet("mat", {
        ns.insert_node(1, { "sample_text" }), ns.text_node(": "),
        ns.match(1, "%d", "contains a number", "no number :("),
    }),

    -- Match Node 2 (Regex set)
    ns.snippet("mat2", {
        ns.insert_node(1, { "sample_text" }), ns.text_node(": "),
        ns.match(1, "[abc][abc][abc]"),
    }),

    -- Match Node 3 (Transform before match)
    ns.snippet("mat3", {
        ns.insert_node(1, { "sample_text" }), ns.text_node(": "),
        ns.match(1, l._1:gsub("[123]", ""):match("%d"), "contains a number that isn't 1, 2 or 3!"),
    }),

    -- Match Node 4 (Function)
    ns.snippet("mat4", {
        ns.insert_node(1, { "sample_text" }), ns.text_node(": "),
        ns.match(1, function(text) return (#text % 2 == 0 and text) or nil end),
    }),

    -- Non-Empty Check
    ns.snippet("nempty", {
        ns.insert_node(1, "sample_text"),
        ns.non_empty(1, "i(1) is not empty!"),
    }),

    -- Dynamic Lambdas
    ns.snippet("dl1", {
        ns.insert_node(1, "sample_text"), ns.text_node({ ":", "" }),
        ns.dynamic_lambda(2, l._1, 1),
    }),

    ns.snippet("dl2", {
        ns.insert_node(1, "sample_text"), ns.insert_node(2, "sample_text_2"), ns.text_node({ "", "" }),
        ns.dynamic_lambda(3, l._1:gsub("\n", " linebreak ") .. l._2, { 1, 2 }),
    }),

    -- ======================================================================
    -- CONDITIONS
    -- ======================================================================

    -- Custom Condition (C-style comments)
    ns.snippet("cond", {
        ns.text_node("will only expand in c-style comments"),
    }, {
        condition = function(line_to_cursor, matched_trigger, captures)
            return line_to_cursor:match("%s*//")
        end,
    }),

    -- Built-in Condition (Line Begin)
    ns.snippet("cond2", {
        ns.text_node("will only expand at the beginning of the line"),
    }, {
        condition = conds.line_begin,
    }),

    -- ======================================================================
    -- FORMAT (FMT / FMTA)
    -- ======================================================================

    -- FMT 1 (Named & Numbered placeholders)
    ns.snippet("fmt1", fmt("To {title} {} {}.", {
        ns.insert_node(2, "Name"),
        ns.insert_node(3, "Surname"),
        title = ns.choice_node(1, { ns.text_node("Mr."), ns.text_node("Ms.") }),
    })),

    -- FMT 2 (Multiline & Repeats)
    ns.snippet("fmt2", fmt([[
        foo({1}, {3}) {{
            return {2} * {4}
        }}
        ]], {
        ns.insert_node(1, "x"), ns.rep(1),
        ns.insert_node(2, "y"), ns.rep(2),
    })),

    -- FMT 3 (Mixed Indexing)
    ns.snippet("fmt3", fmt("{} {a} {} {1} {}", {
        ns.text_node("1"), ns.text_node("2"), a = ns.text_node("A"),
    })),

    -- FMT 4 (Custom Delimiters)
    ns.snippet("fmt4", fmt("foo() { return []; }", ns.insert_node(1, "x"), { delimiters = "[]" })),

    -- FMTA (Angle Brackets)
    ns.snippet("fmt5", fmta("foo() { return <>; }", ns.insert_node(1, "x"))),

    -- FMT 6 (Non-Strict)
    ns.snippet("fmt6", fmt("use {} only", { ns.text_node("this"), ns.text_node("not this") }, { strict = false })),

    -- ======================================================================
    -- UNICODE & EDGE CASES
    -- ======================================================================

    ns.snippet("test1", {
        ns.insert_node(1, "ቒ"), ns.insert_node(3), ns.insert_node(2), ns.insert_node(0), ns.insert_node(4)
    }),

    ns.snippet({ trig = "tt" }, {
        ns.text_node({ "╔" }),
        ns.func_node(function() return { "e" } end, {}),
        ns.text_node({ "1", "2" }),
        ns.insert_node(0),
    }),

    -- Auto-Exit on finish
    ns.snippet({ trig = "trig" }, {
        ns.text_node({ "lel", "\t" }),
        ns.insert_node(1, "lol"), ns.text_node({ "lel", "\t" }),
        ns.text_node({ "lel", "lel" })
    }, {
        callbacks = {
            [-1] = { [events.enter] = function() print("1!!") end },
            [0]  = {
                [events.enter] = function(node)
                    vim.schedule(function()
                        node.parent.snippet:exit()
                        ls.session.current_nodes[vim.api.nvim_get_current_buf()] = nil
                    end)
                end
            }
        }
    }),

    -- ======================================================================
    -- PARSED SNIPPETS (VSCode Style)
    -- ======================================================================

    ns.ls.parser.parse_snippet(
        "lspsyn",
        "Wow! This ${1:Stuff} really ${2:works. ${3:Well, a bit.}}"
    ),

    ns.ls.parser.parse_snippet(
        { trig = "te", wordTrig = false },
        "${1:cond} ? ${2:true} : ${3:false}"
    ),
}
