-- ==========================================================================
-- THEME CONFIGURATION
-- ==========================================================================
-- lua/plugins/theme.lua
-- This file configures the active colorscheme (Kanagawa) and UI elements
-- like diagnostic signs and transparency overrides.

-- Import user environment settings
local env = require("config.user_env").config

return {
	-- ==========================================================================
	-- 1. KANAGAWA THEME
	-- ==========================================================================
	{
		"rebelot/kanagawa.nvim",
		lazy = false, -- Load immediately during startup
		priority = 1000, -- Load before other UI plugins

		config = function()
			-- ----------------------------------------------------------------------
			-- 1. UI Setup: Diagnostic Signs
			-- ----------------------------------------------------------------------
			-- Define custom icons for LSP diagnostics in the sign column.
			vim.diagnostic.config({
				virtual_text  = true,
				signs         = {
					text      = {
						[vim.diagnostic.severity.ERROR] = "✘",
						[vim.diagnostic.severity.WARN]  = "",
						[vim.diagnostic.severity.HINT]  = "⚑",
						[vim.diagnostic.severity.INFO]  = "»",
					},
				},
				underline     = true,
				severity_sort = true,
				float         = { border = "rounded" },
			})

			-- ----------------------------------------------------------------------
			-- 2. Theme Configuration
			-- ----------------------------------------------------------------------
			require("kanagawa").setup({
				compile        = true, -- Enable compiling the colorscheme
				undercurl      = true, -- Enable undercurls
				commentStyle   = { italic = true },
				keywordStyle   = { italic = true },
				statementStyle = { bold   = true },
				transparent    = env.transparent, -- Use setting from user_env.lua

				-- ------------------------------------------------------------------
				-- Overrides
				-- ------------------------------------------------------------------
				-- Customizes specific highlight groups.
				-- Note: We use 'colors.theme.ui' to access palette colors.
				overrides = function(colors)
					local theme = colors.theme
				end,
			})

			-- ----------------------------------------------------------------------
			-- 3. Load Colorscheme
			-- ----------------------------------------------------------------------
			-- Applies the theme defined in user_env (defaults to "kanagawa")
			vim.cmd.colorscheme(env.theme)

			-- ----------------------------------------------------------------------
			-- 4. Overwriting some stubborn HL_Groups
			-- ----------------------------------------------------------------------
			local groups = {
				-- 1. Editor UI
				"LineNr",
				"Cmdline",
				"MsgArea",
				"FloatBorder",
				"Pmenu",
				"CursorLineNr",
				"SignColumn",
				"VertSplit",
				"WinSeparator",

				-- 2. LSP Diagnostic Signs
				"DiagnosticSignError",
				"DiagnosticSignWarn",
				"DiagnosticSignInfo",
				"DiagnosticSignHint",

				-- 3. GitSigns
				"GitSignsAdd",
				"GitSignsChange",
				"GitSignsDelete",

				-- 4. Floating Windows & Borders
				"Normal",
				"NormalNC",
				"NormalFloat",
				-- "FloatBorder" (Duplicate, already listed above)

				-- 5. Custom / Misc
				"SaveAsRoot",

				-- 6. Additional Diagnostic Groups
				"DiagnosticError",
				"DiagnosticWarn",
				"DiagnosticInfo",
				"DiagnosticHint",

				"DiagnosticVirtualTextError",
				"DiagnosticVirtualTextWarn",
				"DiagnosticVirtualTextInfo",
				"DiagnosticVirtualTextHint",

				"DiagnosticUnderlineError",
				"DiagnosticUnderlineWarn",
				"DiagnosticUnderlineInfo",
				"DiagnosticUnderlineHint",

				"LspDiagnosticsDefaultError",
				"LspDiagnosticsDefaultWarning",
				"LspDiagnosticsDefaultInformation",
				"LspDiagnosticsDefaultHint",
			}

			for _, g in ipairs(groups) do
				vim.api.nvim_set_hl(0, g, { bg = "none" })
			end
		end,
	},
}
