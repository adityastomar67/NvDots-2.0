-- ==========================================================================
-- COMPLETION CONFIGURATION (Optimized with blink.cmp)
-- ==========================================================================
-- lua/plugins/completion.lua

return {
    -- ==========================================================================
    -- 1. SNIPPET ENGINE (Kept for your custom local snippets)
    -- ==========================================================================
    {
        "L3MON4D3/LuaSnip",
        version = "v2.*",
        build = "make install_jsregexp",
        dependencies = { "rafamadriz/friendly-snippets" },
        event = "InsertEnter",

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
    -- 2. COMPLETION ENGINE (blink.cmp)
    -- ==========================================================================
    {
        'saghen/blink.cmp',
        version = '1.*',
        dependencies = {
            'brenoprata10/nvim-highlight-colors',
            'folke/lazydev.nvim',
            'MahanRahmati/blink-nerdfont.nvim',
            'moyiz/blink-emoji.nvim',
            -- 'rafamadriz/friendly-snippets', -- Removed here as it is loaded by LuaSnip above
            {
                'Kaiser-Yang/blink-cmp-git',
                dependencies = { 'nvim-lua/plenary.nvim' },
            },
            {
                'onsails/lspkind.nvim',
                opts = {},
            },
        },

        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- Tell blink to use LuaSnip to power its snippet expansions
            snippets = { preset = 'luasnip' },

            appearance = { nerd_font_variant = 'mono' },
            signature = { enabled = true },

            keymap = {
                preset = 'default',
                ['<CR>'] = { 'accept', 'fallback' },
                ['<C-k>'] = { 'fallback' }, -- Override blink.cmp's default signature help to allow global `<C-k>` (Up) mapping to run
            },

            completion = {
                documentation = { auto_show = true },
                list = { selection = { preselect = true, auto_insert = true } },
                menu = {
                    draw = {
                        components = {
                            kind_icon = {
                                text = function(ctx)
                                    local icon = ctx.kind_icon
                                    if ctx.item.source_name == 'LSP' then
                                        local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                                        if color_item and color_item.abbr then
                                            icon = color_item.abbr
                                        else
                                            icon = require('lspkind').symbolic(ctx.kind, { mode = 'symbol' })
                                        end
                                    elseif vim.tbl_contains({ 'Path' }, ctx.source_name) then
                                        local dev_icon, _ = require('nvim-web-devicons').get_icon(ctx.label)
                                        if dev_icon then
                                            icon = dev_icon
                                        end
                                    end
                                    return icon .. ctx.icon_gap
                                end,
                                highlight = function(ctx)
                                    local highlight = 'BlinkCmpKind' .. ctx.kind
                                    if ctx.item.source_name == 'LSP' then
                                        local color_item = require('nvim-highlight-colors').format(ctx.item.documentation, { kind = ctx.kind })
                                        if color_item and color_item.abbr_hl_group then
                                            highlight = color_item.abbr_hl_group
                                        end
                                    end
                                    return highlight
                                end,
                            },
                        },
                    },
                },
            },

            sources = {
                default = { 'git', 'lsp', 'path', 'snippets', 'buffer', 'emoji', 'nerdfont' },
                providers = {
                    git = {
                        module = 'blink-cmp-git',
                        name = 'Git',
                        enabled = function()
                            return vim.tbl_contains({ 'octo', 'gitcommit', 'markdown' }, vim.bo.filetype)
                        end,
                        opts = {
                            -- TODO: get neogit working
                        },
                    },
                    lazydev = {
                        name = 'LazyDev',
                        module = 'lazydev.integrations.blink',
                        score_offset = 100,
                    },
                    nerdfont = {
                        module = 'blink-nerdfont',
                        name = 'Nerd Fonts',
                        score_offset = 15,
                        opts = { insert = true },
                    },
                    emoji = {
                        module = 'blink-emoji',
                        name = 'Emoji',
                        score_offset = 25,
                        opts = { insert = true },
                    },
                },
                per_filetype = {
                    lua = { inherit_defaults = true, 'lazydev' },
                },
            },
            fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
        opts_extend = { 'sources.default' },
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
