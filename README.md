# NvDots-2.0

A modern, blazing fast, and minimalistic Neovim configuration built with Lua. Designed for efficiency, it features a clean file structure, lazy-loading for performance, and a curated selection of essential tools.

## ✨ Features

* **⚡ Speed First:** Optimized startup time using `lazy.nvim` package manager.
* **🛠️ LSP Zero-Config:** Minimal, single-file LSP setup using `Mason` and `nvim-lspconfig` for auto-installing servers, linters, and formatters.
* **🔭 Modern Finder:** Replaced Telescope with **Snacks.picker** for a faster, cleaner fuzzy finding experience.
* **🎨 Aesthetics:** Custom minimal dashboard and the beautiful `Kanagawa` theme with transparency support.
* **🧘 Zen Mode:** Distraction-free coding mode powered by `Limelight` and custom logic.
* **🔌 Custom Utils:** Integrated boolean toggler (`true` <-> `false`), code runner, and text manipulation tools.

## 📂 Config Structure

```text
NvDots-2.0
├── after/                     # Filetype specific tweaks (indent, syntax, etc.)
├── bin/snippets/              # Custom snippets location
├── init.lua                   # Entry point (bootstraps Lazy.nvim)
├── lua/
│   ├── config/                # Core Configuration
│   │   ├── autocmds.lua       # Auto commands & custom user commands (:Cls, :Run)
│   │   ├── keymaps.lua        # Global keybindings
│   │   ├── lazy.lua           # Plugin manager setup
│   │   ├── options.lua        # Neovim options (vim.opt.*)
│   │   └── user_env.lua       # Centralized control (Theme, Toggles, Feature Flags)
│   ├── plugins/              
│   │   ├── colorscheme.lua    # Theme config
│   │   ├── completions.lua    # Autocomplete (Cmp) & Snippets
│   │   ├── editor.lua         # Text editing tools (Autopairs, Comments)
│   │   ├── lsp.lua            # One-file LSP + Mason + Treesitter setup
│   │   └── ui.lua             # UI plugins (Statusline, Icons)
│   └── util/                 
│       ├── dash.lua           # Lightweight custom dashboard
│       ├── toggler.lua        # Word toggler logic
│       ├── utils.lua          # Helper functions
│       └── zen.lua            # Zen mode logic
└── README.md


# TODO
## Bad habbits of using arrow
## Custom snippets with multiple options using lua snip snippets

