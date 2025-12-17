-- ==========================================================================
-- GIT COMMIT SNIPPETS
-- ==========================================================================
-- lua/snippets/git.lua
-- Snippets for standardizing git commit messages (Conventional Commits).

local ns                                        = require("util.utils").node_snip
local utils                                     = require("luasnip_snippets.utils")

return {
    git = {
        -- ======================================================================
        -- 1. CONVENTIONAL COMMIT
        -- ======================================================================
        -- Format: type(scope): description
        -- TODO: Upgrade to choice_node for types (feat, fix, etc.)
        -- TODO: Upgrade to choice_node for scope toggle
        ns.snippet("git conv commit", {
            ns.insert_node(1, "type"),
            ns.text_node("("),
            ns.insert_node(2, "scope"),
            ns.text_node("): "),
            ns.insert_node(3, "description"),
        }),

        -- ======================================================================
        -- 2. USER CONFIG COMMIT
        -- ======================================================================
        -- Automatically fetches the current git user from config.
        -- Format: user(git_username): description
        ns.snippet("git user commit", {
            ns.text_node("user("),
            ns.func_node(utils.bash, {}, "git config github.user"),
            ns.text_node("): "),
            ns.insert_node(1, "description"),
        }),
    }
}
