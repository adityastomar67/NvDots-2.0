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
					return {
						-- 1. Editor UI (Transparency & Splits)
						LineNr                           = { bg = "NONE" },
						CursorLineNr                     = { bg = "NONE" },
						SignColumn                       = { bg = "NONE" },
						VertSplit                        = { fg = theme.ui.bg_m3, bg = "NONE" },
						WinSeparator                     = { fg = theme.ui.bg_m3, bg = "NONE" },

						-- 2. LSP Diagnostic Signs (Remove Backgrounds)
						DiagnosticSignError              = { bg = "NONE" },
						DiagnosticSignWarn               = { bg = "NONE" },
						DiagnosticSignInfo               = { bg = "NONE" },
						DiagnosticSignHint               = { bg = "NONE" },

						-- 3. GitSigns (Remove Backgrounds)
						GitSignsAdd                      = { bg = "NONE" },
						GitSignsChange                   = { bg = "NONE" },
						GitSignsDelete                   = { bg = "NONE" },

						-- 4. Floating Windows & Borders
						NormalFloat                      = { bg = "NONE" },
						FloatBorder                      = { bg = "NONE" },

						-- 5. Custom / Misc
						SaveAsRoot                       = { fg = theme.ui.fg_dim, bg = "NONE" },

						-- 6. Additional Diagnostic Groups (New & Legacy)
						DiagnosticError                  = { bg = "NONE" },
						DiagnosticWarn                   = { bg = "NONE" },
						DiagnosticInfo                   = { bg = "NONE" },
						DiagnosticHint                   = { bg = "NONE" },

						DiagnosticVirtualTextError       = { bg = "NONE" },
						DiagnosticVirtualTextWarn        = { bg = "NONE" },
						DiagnosticVirtualTextInfo        = { bg = "NONE" },
						DiagnosticVirtualTextHint        = { bg = "NONE" },

						DiagnosticUnderlineError         = { bg = "NONE" },
						DiagnosticUnderlineWarn          = { bg = "NONE" },
						DiagnosticUnderlineInfo          = { bg = "NONE" },
						DiagnosticUnderlineHint          = { bg = "NONE" },

						LspDiagnosticsDefaultError       = { bg = "NONE" },
						LspDiagnosticsDefaultWarning     = { bg = "NONE" },
						LspDiagnosticsDefaultInformation = { bg = "NONE" },
						LspDiagnosticsDefaultHint        = { bg = "NONE" },
					}
				end,
			})

			-- ----------------------------------------------------------------------
			-- 3. Load Colorscheme
			-- ----------------------------------------------------------------------
			-- Applies the theme defined in user_env (defaults to "kanagawa")
			vim.cmd.colorscheme(env.theme)
		end,
	},
}
