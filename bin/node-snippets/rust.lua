-- ==========================================================================
-- RUST SNIPPETS
-- ==========================================================================
-- lua/snippets/rust.lua
-- Essential snippets for Rust programming, including testing and macros.

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    rust = {
        -- ======================================================================
        -- 1. FUNCTIONS & MODULES
        -- ======================================================================

        -- Main Function
        ns.snippet("main", {
            ns.text_node({ "fn main() {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- Public Function (Parsed)
        ns.ls.parser.parse_snippet(
            { trig = "pfn", name = "Public Function" },
            [[
/// $1
pub fn ${2:name}($3) ${4:-> ${5:Result<T, E>}} \{
    $0
\}
]]
        ),

        -- Private Function (Parsed)
        ns.ls.parser.parse_snippet(
            { trig = "fn", name = "Function" },
            [[
/// $1
fn ${2:name}($3) ${4:-> ${5:i32}} \{
    $0
\}
]]
        ),

        -- Test Function
        ns.snippet("test", {
            ns.text_node({ "#[test]", "fn " }),
            ns.insert_node(1, "test_name"),
            ns.text_node({ "() {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- Test Module Boilerplate
        ns.snippet("modtest", {
            ns.text_node({ "#[cfg(test)]", "mod tests {", "\tuse super::*;", "", "\t#[test]", "\tfn " }),
            ns.insert_node(1, "it_works"),
            ns.text_node({ "() {", "\t\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "\t}", "}" }),
        }),

        -- ======================================================================
        -- 2. DATA STRUCTURES
        -- ======================================================================

        -- Struct
        ns.snippet("struct", {
            ns.text_node("struct "),
            ns.insert_node(1, "Name"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- Enum
        ns.snippet("enum", {
            ns.text_node("enum "),
            ns.insert_node(1, "Name"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- Impl Block
        ns.snippet("impl", {
            ns.text_node("impl "),
            ns.insert_node(1, "Type"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- Impl Trait
        ns.snippet("implt", {
            ns.text_node("impl "),
            ns.insert_node(1, "Trait"),
            ns.text_node(" for "),
            ns.insert_node(2, "Type"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- ======================================================================
        -- 3. MACROS & UTILITIES
        -- ======================================================================

        -- Println
        ns.snippet("pl", {
            ns.text_node("println!(\"{}\", "),
            ns.insert_node(1, "var"),
            ns.text_node(");"),
        }),

        -- Println (Debug)
        ns.snippet("pld", {
            ns.text_node("println!(\"{:?}\", "),
            ns.insert_node(1, "var"),
            ns.text_node(");"),
        }),

        -- Derive Macro
        ns.snippet("der", {
            ns.text_node("#[derive("),
            ns.insert_node(1, "Debug, Clone"),
            ns.text_node(")]"),
        }),

        -- Allow/Warn/Deny Attribute
        ns.snippet("allow", {
            ns.text_node("#[allow("),
            ns.insert_node(1, "dead_code"),
            ns.text_node(")]"),
        }),

        -- ======================================================================
        -- 4. CONTROL FLOW
        -- ======================================================================

        -- Match Statement
        ns.snippet("match", {
            ns.text_node("match "),
            ns.insert_node(1, "variable"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(2, "Pattern"),
            ns.text_node(" => "),
            ns.insert_node(3, "Expression"),
            ns.text_node({ ",", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- If Let
        ns.snippet("iflet", {
            ns.text_node("if let "),
            ns.choice_node(1, {
                ns.text_node("Some("),
                ns.text_node("Ok("),
            }),
            ns.insert_node(2, "x"),
            ns.text_node(") = "),
            ns.insert_node(3, "expression"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),

        -- For Loop
        ns.snippet("for", {
            ns.text_node("for "),
            ns.insert_node(1, "i"),
            ns.text_node(" in "),
            ns.insert_node(2, "iterator"),
            ns.text_node({ " {", "\t" }),
            ns.insert_node(0),
            ns.text_node({ "", "}" }),
        }),
    }
}
