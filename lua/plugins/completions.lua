-- ==========================================================================
-- COMPLETION CONFIGURATION (Optimized)
-- ==========================================================================
-- lua/plugins/completion.lua

-- Define icons once (outside the module to save memory on reload)
local kind_icons = {
    Text = "", Method = "󰆧", Function = "󰊕", Constructor = "",
    Field = "󰇽", Variable = "󰂡", Class = "󰠱", Interface = "",
    Module = "", Property = "󰜢", Unit = "", Value = "󰎠",
    Enum = "", Keyword = "󰌋", Snippet = "", Color = "󰏘",
    File = "󰈙", Reference = "", Folder = "󰉋", EnumMember = "",
    Constant = "󰏿", Struct = "", Event = "", Operator = "󰆕",
    TypeParameter = "󰅲", Copilot = "",
}

return {
    -- ==========================================================================
    -- 1. SNIPPET ENGINE
    -- ==========================================================================
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "InsertEnter", -- Lazy load on Insert

        config = function()
            local ls = require("luasnip")
            local types = require("luasnip.util.types")
            local config_path = vim.fn.stdpath("config")

            -- Loaders
            require("luasnip.loaders.from_vscode").lazy_load()

            -- Custom User Snippets (Fail silently if folders don't exist)
            pcall(function()
                require("luasnip.loaders.from_snipmate").lazy_load({ paths = { config_path .. "/bin/snippets" } })
                require("luasnip.loaders.from_lua").lazy_load({ paths = { config_path .. "/bin/node_snippets/" } })
            end)

            ls.config.setup({
                history = true,
                update_events = "TextChanged,TextChangedI",
                enable_autosnippets = true,
                store_selection_keys = "<A-p>",
                ext_opts = {
                    [types.choiceNode] = {
                        active = { virt_text = { { "●", "GruvboxOrange" } } },
                    },
                },
            })
        end,
    },

    -- ==========================================================================
    -- 2. COMPLETION ENGINE
    -- ==========================================================================
    {
        "hrsh7th/nvim-cmp",
        version = false,
        event = { "InsertEnter", "CmdlineEnter" },
        dependencies = {
            "hrsh7th/cmp-nvim-lsp",
            "hrsh7th/cmp-buffer",
            "hrsh7th/cmp-path",
            "hrsh7th/cmp-cmdline",
            "saadparwaiz1/cmp_luasnip",
            "windwp/nvim-autopairs",
        },

        config = function()
            local cmp = require("cmp")
            local luasnip = require("luasnip")

            -- Integration with Autopairs
            local cmp_autopairs = require("nvim-autopairs.completion.cmp")
            cmp.event:on("confirm_done", cmp_autopairs.on_confirm_done())

            cmp.setup({
                snippet = {
                    expand = function(args)
                        luasnip.lsp_expand(args.body)
                    end,
                },

                window = {
                    completion    = cmp.config.window.bordered(),
                    documentation = cmp.config.window.bordered(),
                },

                -- Use your existing keymap config
                mapping = cmp.mapping.preset.insert(require("config.keymaps").cmp(cmp, luasnip)),

                formatting = {
                    fields = { "kind", "abbr", "menu" }, -- Icon, Text, Source
                    format = function(entry, vim_item)
                        -- 1. Set Icon
                        vim_item.kind = string.format("%s %s", kind_icons[vim_item.kind] or "", vim_item.kind)

                        -- 2. Set Source Menu
                        vim_item.menu = ({
                            nvim_lsp = "[LSP]",
                            luasnip  = "[Snip]",
                            buffer   = "[Buf]",
                            path     = "[Path]",
                        })[entry.source.name]

                        return vim_item
                    end,
                },

                sources = cmp.config.sources({
                    { name = "nvim_lsp", group_index = 1 }, -- High Priority
                    { name = "luasnip",  group_index = 1 }, -- High Priority
                    { name = "path",     group_index = 2 },
                }, {
                    { name = "buffer",   group_index = 3 }, -- Lower Priority (reduces noise)
                }),

                experimental = {
                    ghost_text = { hl_group = "Comment" },
                },
            })

            -- ==================================================================
            -- MISSING CONFIG: Command Line Setup
            -- ==================================================================

            -- Search (/)
            cmp.setup.cmdline('/', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = {
                    { name = 'buffer' }
                }
            })

            -- Command (:)
            cmp.setup.cmdline(':', {
                mapping = cmp.mapping.preset.cmdline(),
                sources = cmp.config.sources({
                    { name = 'path' }
                }, {
                    { name = 'cmdline' }
                })
            })
        end,
    },

    -- ==========================================================================
    -- 3. UTILS
    -- ==========================================================================
    {
        "windwp/nvim-autopairs",
        event = "InsertEnter",
        config = true,
    },
}
