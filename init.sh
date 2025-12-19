#!/bin/bash

# ==============================================================================
#  NvDots-2.0 INSTALLER
# ==============================================================================
#  A beautiful, safe, and extensive installer for your Neovim configuration.
# ==============================================================================

# ------------------------------------------------------------------------------
# 1. VISUAL SETTINGS (COLORS & FORMATTING)
# ------------------------------------------------------------------------------
# Reset
RESET='\033[0m'

# Palette
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
MAGENTA='\033[0;35m'
WHITE='\033[1;37m'
DIM='\033[2m'

# Icons
ICON_OK="[${GREEN}OK${RESET}]"
ICON_ERR="[${RED}ERR${RESET}]"
ICON_WARN="[${YELLOW}!!${RESET}]"
ICON_INFO="[${BLUE}INFO${RESET}]"
ICON_GEAR="⚙️"
ICON_ROCKET="🚀"
ICON_TRASH="🗑️"
ICON_PKG="📦"
ICON_BACKUP="💾"
ICON_SHELL="🐚"

# Repository URL (CHANGE THIS IF NEEDED)
REPO_URL="https://github.com/adityastomar67/NvDots-2.0.git"
INSTALL_DIR="$HOME/.config/nvim"

# ------------------------------------------------------------------------------
# 2. HELPER FUNCTIONS
# ------------------------------------------------------------------------------

# Header Display
show_banner() {
    clear
    echo -e "${MAGENTA}"
    echo "    _   __      ____       __               ___   ____ "
    echo "   / | / /_  __/ __ \____ / /______        |__ \ / __ \\"
    echo "  /  |/ /| |/_/ / / / __ / __/ ___/________/ // / / / /"
    echo " / /|  /_>  </ /_/ / /_/ / /_(__  )_______/ __// /_/ / "
    echo "/_/ |_/ /_/_/_____/\____/\__/____/       /____/\____/  "
    echo -e "${RESET}"
    echo -e "   ${DIM}:: The Modern Neovim Experience ::${RESET}\n"
}

# Spinner logic for long-running tasks
spinner() {
    local pid=$1
    local delay=0.1
    local spinstr='|/-\'
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        local temp=${spinstr#?}
        printf " [%c]  " "$spinstr"
        local spinstr=$temp${spinstr%"$temp"}
        sleep $delay
        printf "\b\b\b\b\b\b"
    done
    printf "    \b\b\b\b"
}

# Nice separator
print_step() {
    echo -e "\n${BOLD}${BLUE}:: $1${RESET}"
    echo -e "${DIM}------------------------------------------------------${RESET}"
}

# Success message
print_success() {
    echo -e "${GREEN}✔ $1${RESET}"
}

# Error handler
error_exit() {
    echo -e "\n${ICON_ERR} ${RED}$1${RESET}"
    exit 1
}

# Check for dependency
check_cmd() {
    if ! command -v "$1" &> /dev/null; then
        echo -e "${ICON_WARN} ${YELLOW}$1 is not installed.${RESET}"
        return 1
    else
        echo -e "${ICON_OK} Found ${CYAN}$1${RESET}"
        return 0
    fi
}

# ------------------------------------------------------------------------------
# 3. MAIN INSTALLATION LOGIC
# ------------------------------------------------------------------------------

show_banner
sleep 1

# --- Step 1: Pre-flight Checks ---
print_step "Checking Prerequisites"

check_cmd "git" || error_exit "Git is required to clone the repository."
check_cmd "nvim" || echo -e "${ICON_WARN} Neovim not found. Ensure you install it later!"
check_cmd "rg" || echo -e "${ICON_WARN} Ripgrep (rg) recommended for fast searching."
check_cmd "gcc" || echo -e "${ICON_WARN} GCC recommended for Treesitter compilation."

echo -e "\n${ICON_INFO} All critical checks passed."
sleep 1


# --- Step 2: Backup Old Config ---
print_step "Backing up existing configurations"

BACKUP_NAME="nvim.backup.$(date +%Y%m%d_%H%M%S)"
DIRS_TO_BACKUP=("$HOME/.config/nvim" "$HOME/.local/share/nvim" "$HOME/.local/state/nvim" "$HOME/.cache/nvim")

for DIR in "${DIRS_TO_BACKUP[@]}"; do
    if [ -d "$DIR" ]; then
        DEST="${DIR}_$BACKUP_NAME"
        echo -ne "   ${ICON_BACKUP} Moving ${WHITE}$DIR${RESET} -> ${DIM}$(basename "$DEST")${RESET}..."
        mv "$DIR" "$DEST" &
        spinner $!
        print_success "Backed up $(basename "$DIR")"
    else
        echo -e "   ${DIM}(Create) ${DIR} does not exist, skipping backup.${RESET}"
    fi
done


# --- Step 3: Deep Cleaning ---
print_step "Cleaning Artifacts & Caches"

RM_DIRS=("$HOME/.local/share/nvim" "$HOME/.cache/nvim" "$HOME/.local/state/nvim")

for DIR in "${RM_DIRS[@]}"; do
    if [ -d "$DIR" ]; then
        echo -ne "   ${ICON_TRASH} Scrubbing ${WHITE}$DIR${RESET}..."
        rm -rf "$DIR" &
        spinner $!
        print_success "Cleaned $(basename "$DIR")"
    fi
done


# --- Step 4: Installation ---
print_step "Installing NvDots-2.0"

echo -ne "   ${ICON_ROCKET} Cloning repository from GitHub..."
git clone --depth 1 "$REPO_URL" "$INSTALL_DIR" > /dev/null 2>&1 &
PID=$!
spinner $PID

wait $PID
if [ $? -eq 0 ]; then
    print_success "Repository cloned successfully to ${INSTALL_DIR}"
else
    error_exit "Failed to clone repository. Check your internet connection or URL."
fi


# --- Step 5: Shell Configuration ---
print_step "Setting up Shell Alias"

ALIAS_CMD='alias v="nvim"'
SHELL_RC=""

# Detect Shell Config File
if [ -f "$HOME/.zshrc" ]; then
    SHELL_RC="$HOME/.zshrc"
elif [ -f "$HOME/.bashrc" ]; then
    SHELL_RC="$HOME/.bashrc"
elif [ -f "$HOME/.bash_profile" ]; then
    SHELL_RC="$HOME/.bash_profile"
fi

if [ -n "$SHELL_RC" ]; then
    # Check if alias already exists to avoid duplicates
    if grep -Fq "alias v=\"nvim\"" "$SHELL_RC" || grep -Fq "alias v='nvim'" "$SHELL_RC"; then
        echo -e "   ${ICON_INFO} Alias 'v' already exists in ${WHITE}$(basename "$SHELL_RC")${RESET}"
    else
        echo -ne "   ${ICON_SHELL} Adding alias to ${WHITE}$(basename "$SHELL_RC")${RESET}..."
        echo "" >> "$SHELL_RC"
        echo "# Neovim Alias (NvDots)" >> "$SHELL_RC"
        echo "$ALIAS_CMD" >> "$SHELL_RC"
        print_success "Added alias ${BOLD}v${RESET} -> ${BOLD}nvim${RESET}"
    fi
else
    echo -e "   ${ICON_WARN} No suitable shell config found (.zshrc or .bashrc). Skipping alias."
fi


# --- Step 6: Post-Install & Headless Bootstrap ---
print_step "Finalizing Setup"

# Ensure packer/lazy bootstrapping works by creating state dir
mkdir -p "$HOME/.local/share/nvim"

echo -e "   ${ICON_PKG} Installing fonts (Manual step recommended if not patched)..."

# HEADLESS BOOTSTRAP
echo -ne "   ${ICON_GEAR} Bootstrapping Lazy.nvim & Plugins (this may take a while)..."

# We run nvim in headless mode, trigger the sync, and capture errors just in case
nvim --headless "+Lazy! sync" +!qa > /dev/null 2>&1 &
PID=$!
spinner $PID

wait $PID
if [ $? -eq 0 ]; then
    print_success "Plugins installed & synced successfully!"
else
    echo -e "   ${ICON_WARN} Some plugins might need manual `:Lazy sync` inside Neovim."
fi

sleep 1
echo -e "\n${GREEN}==============================================${RESET}"
echo -e "${BOLD}       INSTALLATION COMPLETE! 🥳${RESET}"
echo -e "${GREEN}==============================================${RESET}"

echo -e "\n${WHITE}Next Steps:${RESET}"
echo -e "  1. Reload your shell: ${BOLD}source ${SHELL_RC:-~/.bashrc}${RESET}"
echo -e "  2. Open Neovim: ${BOLD}v${RESET}"
echo -e "  3. Run ${CYAN}:Mason${RESET} to install your LSP servers."
echo -e "\n${DIM}Enjoy your new editor!${RESET}\n"
