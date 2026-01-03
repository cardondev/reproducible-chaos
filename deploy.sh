#!/bin/bash
# =============================================================================
# DEPLOY.SH - Dotfiles Deployment Script
# Safely installs configuration files on RHEL 7+ systems
# Supports both prefix mode and native overwrite mode
# =============================================================================

set -euo pipefail

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_PREFIX=".dotfiles"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d%H%M%S)"
INSTALL_MODE=""

# Colors
RED='\e[38;5;203m'
GREEN='\e[38;5;151m'
YELLOW='\e[38;5;223m'
BLUE='\e[38;5;111m'
CYAN='\e[38;5;116m'
MAGENTA='\e[38;5;183m'
RESET='\e[0m'
BOLD='\e[1m'

# -----------------------------------------------------------------------------
# Helper Functions
# -----------------------------------------------------------------------------
log_info() { echo -e "${BLUE}[INFO]${RESET} $1"; }
log_success() { echo -e "${GREEN}[OK]${RESET} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${RESET} $1"; }
log_error() { echo -e "${RED}[ERROR]${RESET} $1"; }
log_section() { echo -e "\n${BOLD}${CYAN}=== $1 ===${RESET}\n"; }

confirm() {
    local prompt="${1:-Continue?}"
    read -p "$(echo -e "${YELLOW}$prompt [y/N]:${RESET} ")" -n 1 -r
    echo
    [[ $REPLY =~ ^[Yy]$ ]]
}

# -----------------------------------------------------------------------------
# System Detection
# -----------------------------------------------------------------------------
detect_system() {
    log_section "System Detection"
    
    if [[ -f /etc/redhat-release ]]; then
        OS_RELEASE=$(cat /etc/redhat-release)
        OS_FAMILY="rhel"
    elif [[ -f /etc/os-release ]]; then
        OS_RELEASE=$(grep PRETTY_NAME /etc/os-release | cut -d'"' -f2)
        OS_FAMILY="other"
    else
        OS_RELEASE="Unknown"
        OS_FAMILY="unknown"
    fi
    
    log_info "OS: $OS_RELEASE"
    log_info "Hostname: $(hostname)"
    log_info "User: $(whoami)"
    log_info "Home: $HOME"
    log_info "Shell: $SHELL"
    log_info "Bash Version: ${BASH_VERSION:-N/A}"
    
    log_info "Checking dependencies..."
    local missing=()
    for cmd in vim bash; do
        if ! command -v "$cmd" &>/dev/null; then
            missing+=("$cmd")
        fi
    done
    
    if command -v tmux &>/dev/null; then
        log_success "tmux: $(tmux -V 2>/dev/null || echo 'installed')"
    else
        log_warn "tmux: not installed (optional)"
    fi
    
    if [[ ${#missing[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing[*]}"
        return 1
    fi
    
    log_success "All required dependencies found"
}

# -----------------------------------------------------------------------------
# Installation Mode Selection
# -----------------------------------------------------------------------------
select_install_mode() {
    log_section "Installation Mode"
    
    echo "Select installation mode:"
    echo ""
    echo -e "  ${CYAN}1) Native Mode${RESET} (Recommended for personal systems)"
    echo "     Overwrites .bashrc, .vimrc, .tmux.conf directly"
    echo "     Uses .bash_aliases and .bash_functions"
    echo "     Original files are backed up"
    echo ""
    echo -e "  ${CYAN}2) Prefix Mode${RESET} (Recommended for shared/managed systems)"
    echo "     Creates separate files like .dotfiles_bashrc"
    echo "     Does not modify original .bashrc (adds sourcing line)"
    echo "     Allows multiple configurations per system"
    echo ""
    
    while true; do
        read -p "$(echo -e "${CYAN}Select mode [1/2]:${RESET} ")" -n 1 -r mode_choice
        echo
        case "$mode_choice" in
            1)
                INSTALL_MODE="native"
                log_info "Selected: Native Mode"
                break
                ;;
            2)
                INSTALL_MODE="prefix"
                log_info "Selected: Prefix Mode"
                break
                ;;
            *)
                log_warn "Invalid choice. Enter 1 or 2."
                ;;
        esac
    done
}

# -----------------------------------------------------------------------------
# Prefix Configuration (for prefix mode)
# -----------------------------------------------------------------------------
configure_prefix() {
    log_section "Configuration Prefix"
    
    echo "The prefix determines the naming convention for config files."
    echo "Examples:"
    echo "  .dotfiles  -> .dotfiles_bashrc, .dotfiles_vimrc, etc."
    echo "  .cardondev -> .cardondev_bashrc, .cardondev_vimrc, etc."
    echo ""
    
    read -p "$(echo -e "${CYAN}Enter prefix [${DEFAULT_PREFIX}]:${RESET} ")" PREFIX
    PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
    
    [[ "$PREFIX" != .* ]] && PREFIX=".$PREFIX"
    
    log_info "Using prefix: $PREFIX"
    
    BASHRC="${PREFIX}_bashrc"
    ALIASES="${PREFIX}_aliases"
    FUNCTIONS="${PREFIX}_functions"
    VIMRC="${PREFIX}_vimrc"
    TMUX_CONF="${PREFIX}_tmux.conf"
}

# -----------------------------------------------------------------------------
# Native Mode Configuration
# -----------------------------------------------------------------------------
configure_native() {
    log_section "Native Mode Configuration"
    
    PREFIX=""
    BASHRC=".bashrc"
    ALIASES=".bash_aliases"
    FUNCTIONS=".bash_functions"
    VIMRC=".vimrc"
    TMUX_CONF=".tmux.conf"
    
    echo "The following files will be replaced:"
    echo -e "  ${YELLOW}~/.bashrc${RESET}        <- Main bash configuration"
    echo -e "  ${YELLOW}~/.bash_aliases${RESET}  <- Command aliases"
    echo -e "  ${YELLOW}~/.bash_functions${RESET}<- Shell functions"
    echo -e "  ${YELLOW}~/.vimrc${RESET}         <- Vim configuration"
    echo -e "  ${YELLOW}~/.tmux.conf${RESET}     <- Tmux configuration"
    echo ""
    echo -e "${RED}${BOLD}WARNING:${RESET} This will overwrite your existing dotfiles!"
    echo "Original files will be backed up to: $BACKUP_DIR"
    echo ""
    
    if ! confirm "Proceed with native installation?"; then
        log_info "Installation cancelled"
        exit 0
    fi
}

# -----------------------------------------------------------------------------
# Backup Existing Configuration
# -----------------------------------------------------------------------------
backup_existing() {
    log_section "Backing Up Existing Configuration"
    
    local files_to_backup=()
    
    if [[ "$INSTALL_MODE" == "native" ]]; then
        for f in ".bashrc" ".bash_aliases" ".bash_functions" ".bash_profile" ".profile" ".vimrc" ".tmux.conf"; do
            [[ -f "$HOME/$f" ]] && files_to_backup+=("$f")
        done
    else
        for f in "$BASHRC" "$ALIASES" "$FUNCTIONS" "$VIMRC" "$TMUX_CONF" ".bashrc"; do
            [[ -f "$HOME/$f" ]] && files_to_backup+=("$f")
        done
    fi
    
    if [[ ${#files_to_backup[@]} -eq 0 ]]; then
        log_info "No existing configuration files to backup"
        return 0
    fi
    
    log_info "Files to backup: ${files_to_backup[*]}"
    
    mkdir -p "$BACKUP_DIR"
    for f in "${files_to_backup[@]}"; do
        cp -a "$HOME/$f" "$BACKUP_DIR/"
        log_success "Backed up: $f -> $BACKUP_DIR/$f"
    done
    log_success "Backup created: $BACKUP_DIR"
    
    cat > "$BACKUP_DIR/restore.sh" << 'RESTORE_EOF'
#!/bin/bash
# Restore script - run this to restore original dotfiles
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "Restoring dotfiles from backup..."
for f in "$SCRIPT_DIR"/.*; do
    [[ -f "$f" ]] || continue
    fname=$(basename "$f")
    [[ "$fname" == "restore.sh" ]] && continue
    cp -a "$f" "$HOME/$fname"
    echo "Restored: $fname"
done
echo "Restore complete. Run 'source ~/.bashrc' to reload."
RESTORE_EOF
    chmod +x "$BACKUP_DIR/restore.sh"
    log_success "Created restore script: $BACKUP_DIR/restore.sh"
}

# -----------------------------------------------------------------------------
# Install Configuration Files - Native Mode
# -----------------------------------------------------------------------------
install_native() {
    log_section "Installing Configuration Files (Native Mode)"
    
    cat > "$HOME/.bashrc" << 'BASHRC_NATIVE_EOF'
#!/bin/bash
# =============================================================================
# BASHRC - Main Shell Configuration
# Theme: Catppuccin Mocha
# Mode: Native Installation
# =============================================================================

# Source global definitions
[[ -f /etc/bashrc ]] && . /etc/bashrc

# -----------------------------------------------------------------------------
# Environment Variables
# -----------------------------------------------------------------------------
export EDITOR="vim"
export VISUAL="vim"
export PAGER="less"
export LANG="en_US.UTF-8"
export LC_ALL="en_US.UTF-8"
export TERM="${TERM:-xterm-256color}"
export HISTTIMEFORMAT="%Y-%m-%d %H:%M:%S %Z  "
export DOTFILES_MODE="native"

# -----------------------------------------------------------------------------
# History Settings
# -----------------------------------------------------------------------------
HISTSIZE=50000
HISTFILESIZE=100000
HISTCONTROL=ignoreboth:erasedups
HISTIGNORE="ls:ll:la:cd:pwd:clear:history:c:exit"

# -----------------------------------------------------------------------------
# Shell Options
# -----------------------------------------------------------------------------
shopt -s histappend
shopt -s checkwinsize
shopt -s cdspell
shopt -s cmdhist
shopt -s dotglob
shopt -s expand_aliases
shopt -s extglob
shopt -s nocaseglob
[[ ${BASH_VERSINFO[0]} -ge 4 ]] && shopt -s globstar
[[ ${BASH_VERSINFO[0]} -ge 4 ]] && shopt -s autocd

# -----------------------------------------------------------------------------
# Catppuccin Mocha Color Palette (256-color compatible)
# -----------------------------------------------------------------------------
C_RESET='\[\e[0m\]'
C_BOLD='\[\e[1m\]'
C_ROSEWATER='\[\e[38;5;224m\]'
C_FLAMINGO='\[\e[38;5;210m\]'
C_PINK='\[\e[38;5;218m\]'
C_MAUVE='\[\e[38;5;183m\]'
C_RED='\[\e[38;5;203m\]'
C_MAROON='\[\e[38;5;181m\]'
C_PEACH='\[\e[38;5;216m\]'
C_YELLOW='\[\e[38;5;223m\]'
C_GREEN='\[\e[38;5;151m\]'
C_TEAL='\[\e[38;5;116m\]'
C_SKY='\[\e[38;5;117m\]'
C_SAPPHIRE='\[\e[38;5;116m\]'
C_BLUE='\[\e[38;5;111m\]'
C_LAVENDER='\[\e[38;5;183m\]'
C_TEXT='\[\e[38;5;189m\]'
C_SUBTEXT1='\[\e[38;5;251m\]'
C_SUBTEXT0='\[\e[38;5;249m\]'
C_OVERLAY2='\[\e[38;5;247m\]'
C_OVERLAY1='\[\e[38;5;245m\]'
C_OVERLAY0='\[\e[38;5;243m\]'
C_SURFACE2='\[\e[38;5;241m\]'
C_SURFACE1='\[\e[38;5;239m\]'
C_SURFACE0='\[\e[38;5;237m\]'
C_BASE='\[\e[38;5;235m\]'
C_MANTLE='\[\e[38;5;234m\]'
C_CRUST='\[\e[38;5;233m\]'

C_TIME="${C_MAUVE}"
C_DATE="${C_MAUVE}"
C_USER="${C_SKY}"
C_HOST="${C_TEAL}"
C_PATH="${C_GREEN}"
C_SEP="${C_YELLOW}"
C_PROMPT="${C_PEACH}"
C_ROOT="${C_RED}"
C_BLINK='\[\e[5m\]'

# -----------------------------------------------------------------------------
# Terminal Capability Detection
# -----------------------------------------------------------------------------
_detect_term_caps() {
    local term_type="${TERM:-dumb}"
    case "$term_type" in
        xterm*|screen*|tmux*|rxvt*|linux|cygwin)
            export TERM_HAS_UNICODE=1
            ;;
        *)
            if [[ -n "$WT_SESSION" ]] || [[ "$TERM_PROGRAM" == "vscode" ]]; then
                export TERM_HAS_UNICODE=1
            else
                export TERM_HAS_UNICODE=0
            fi
            ;;
    esac
    [[ -n "$PUTTY_TERM" ]] || [[ "$TERM" == "putty"* ]] && export TERM_HAS_UNICODE=0
}
_detect_term_caps

# -----------------------------------------------------------------------------
# Prompt Characters (ASCII fallback for PuTTY)
# -----------------------------------------------------------------------------
if [[ "$TERM_HAS_UNICODE" -eq 1 ]]; then
    P_TL="┌"
    P_ML="├"
    P_BL="└"
    P_H="─"
    P_SEP="═-"
    P_ARROW="❯❯❯"
    P_BOLT="⚡"
    P_LBRACKET="["
    P_RBRACKET="]"
else
    P_TL="+"
    P_ML="|"
    P_BL="+"
    P_H="-"
    P_SEP="=-"
    P_ARROW=">>>"
    P_BOLT="#"
    P_LBRACKET="["
    P_RBRACKET="]"
fi

# -----------------------------------------------------------------------------
# Command Separator Function
# -----------------------------------------------------------------------------
command_separator() {
    local cols="${COLUMNS:-$(tput cols 2>/dev/null || echo 80)}"
    local sep=""
    local pattern="${P_SEP}"
    local pattern_len=${#pattern}
    local i=0
    while [[ $i -lt $cols ]]; do
        sep+="${pattern}"
        ((i+=pattern_len))
    done
    sep="${sep:0:$cols}"
    echo -e "\e[38;5;223m${sep}\e[0m"
}

# -----------------------------------------------------------------------------
# Prompt Construction
# -----------------------------------------------------------------------------
_build_prompt() {
    local exit_code=$?
    local time_str=$(date '+%H:%M:%S %Z')
    local date_str=$(date '+%A, %B %d, %Y')
    local user_host="${USER}@${HOSTNAME%%.*}"
    local cwd="${PWD/#$HOME/~}"
    
    local prompt_char="${P_ARROW}"
    local prompt_color="${C_PROMPT}"
    if [[ $EUID -eq 0 ]]; then
        prompt_char="${P_BOLT}${P_ARROW}"
        prompt_color="${C_ROOT}${C_BLINK}"
    fi
    
    local exit_indicator=""
    [[ $exit_code -ne 0 ]] && exit_indicator="${C_RED}[!${exit_code}]${C_RESET} "
    
    PS1=""
    PS1+="${C_SEP}${P_TL}${P_H}${P_LBRACKET}${C_TIME}${time_str}${C_SEP}${P_RBRACKET}"
    PS1+="${P_H}${P_LBRACKET}${C_DATE}${date_str}${C_SEP}${P_RBRACKET}"
    PS1+="${P_H}${P_LBRACKET}${C_USER}${user_host}${C_SEP}${P_RBRACKET}${C_RESET}\n"
    PS1+="${C_SEP}${P_ML}${P_H}${P_LBRACKET}${C_PATH}${cwd}${C_SEP}${P_RBRACKET}${C_RESET}\n"
    PS1+="${C_SEP}${P_BL}${P_H}${C_RESET}${exit_indicator}${prompt_color}${prompt_char}${C_RESET} "
}

PROMPT_COMMAND='command_separator; _build_prompt'

# -----------------------------------------------------------------------------
# Source Additional Configuration Files
# -----------------------------------------------------------------------------
[[ -f "$HOME/.bash_aliases" ]] && . "$HOME/.bash_aliases"
[[ -f "$HOME/.bash_functions" ]] && . "$HOME/.bash_functions"

# -----------------------------------------------------------------------------
# Welcome Message
# -----------------------------------------------------------------------------
_show_welcome() {
    [[ -n "$DOTFILES_NO_WELCOME" ]] && return
    clear
    turbo_mode 2>/dev/null || true
    echo ""
    sysinfo 2>/dev/null || true
    echo ""
    echo -e "\e[38;5;151mWelcome to the Matrix\e[0m"
    echo ""
}

[[ -z "$DOTFILES_SOURCED" ]] && _show_welcome
export DOTFILES_SOURCED=1
BASHRC_NATIVE_EOF
    log_success "Installed: ~/.bashrc"

    sed 's/\${DOTFILES_PREFIX}_bashrc/.bashrc/g; s/\${DOTFILES_PREFIX}_aliases/.bash_aliases/g; s/\${DOTFILES_PREFIX}_functions/.bash_functions/g; s/\${DOTFILES_PREFIX}_vimrc/.vimrc/g; s/\${DOTFILES_PREFIX}_tmux.conf/.tmux.conf/g' "$SCRIPT_DIR/aliases" > "$HOME/.bash_aliases"
    chmod 644 "$HOME/.bash_aliases"
    log_success "Installed: ~/.bash_aliases"
    
    sed 's/\${DOTFILES_PREFIX}_bashrc/.bashrc/g; s/\${DOTFILES_PREFIX}_aliases/.bash_aliases/g; s/\${DOTFILES_PREFIX}_functions/.bash_functions/g; s/\${DOTFILES_PREFIX}_vimrc/.vimrc/g; s/\${DOTFILES_PREFIX}_tmux.conf/.tmux.conf/g' "$SCRIPT_DIR/functions" > "$HOME/.bash_functions"
    chmod 644 "$HOME/.bash_functions"
    log_success "Installed: ~/.bash_functions"
    
    cp "$SCRIPT_DIR/vimrc" "$HOME/.vimrc"
    chmod 644 "$HOME/.vimrc"
    log_success "Installed: ~/.vimrc"
    
    cp "$SCRIPT_DIR/tmux.conf" "$HOME/.tmux.conf"
    chmod 644 "$HOME/.tmux.conf"
    log_success "Installed: ~/.tmux.conf"
    
    if [[ ! -f "$HOME/.bash_profile" ]] || ! grep -q "source.*\.bashrc" "$HOME/.bash_profile" 2>/dev/null; then
        cat >> "$HOME/.bash_profile" << 'PROFILE_EOF'

# Source .bashrc for login shells
if [[ -f "$HOME/.bashrc" ]]; then
    source "$HOME/.bashrc"
fi
PROFILE_EOF
        log_success "Updated: ~/.bash_profile"
    fi
}

# -----------------------------------------------------------------------------
# Install Configuration Files - Prefix Mode
# -----------------------------------------------------------------------------
install_prefix() {
    log_section "Installing Configuration Files (Prefix Mode)"
    
    declare -A file_map=(
        ["bashrc"]="$HOME/$BASHRC"
        ["aliases"]="$HOME/$ALIASES"
        ["functions"]="$HOME/$FUNCTIONS"
        ["vimrc"]="$HOME/$VIMRC"
        ["tmux.conf"]="$HOME/$TMUX_CONF"
    )
    
    for src in "${!file_map[@]}"; do
        local src_file="$SCRIPT_DIR/$src"
        local dst_file="${file_map[$src]}"
        
        if [[ ! -f "$src_file" ]]; then
            log_warn "Source not found: $src_file"
            continue
        fi
        
        sed "s/\${DOTFILES_PREFIX:-\.dotfiles}/${PREFIX}/g" "$src_file" > "$dst_file"
        chmod 644 "$dst_file"
        log_success "Installed: $dst_file"
    done
}

# -----------------------------------------------------------------------------
# Configure Shell Integration (Prefix Mode Only)
# -----------------------------------------------------------------------------
configure_shell_prefix() {
    log_section "Shell Integration"
    
    local bashrc_source="
# =============================================================================
# Dotfiles Integration (added by deploy.sh)
# Prefix: $PREFIX
# =============================================================================
export DOTFILES_PREFIX=\"$PREFIX\"
export VIMINIT='let \$MYVIMRC=\"\$HOME/${VIMRC}\" | source \$MYVIMRC'
if [[ -f \"\$HOME/${BASHRC}\" ]]; then
    source \"\$HOME/${BASHRC}\"
fi
# =============================================================================
"
    
    local current_bashrc="$HOME/.bashrc"
    
    echo ""
    echo "To activate the configuration, add the following to ~/.bashrc:"
    echo ""
    echo -e "${CYAN}$bashrc_source${RESET}"
    echo ""
    
    if confirm "Append to ~/.bashrc automatically?"; then
        if grep -q "DOTFILES_PREFIX=\"$PREFIX\"" "$current_bashrc" 2>/dev/null; then
            log_warn "Integration already exists in ~/.bashrc"
        else
            cp "$current_bashrc" "${current_bashrc}.pre_dotfiles_$(date +%Y%m%d%H%M%S)" 2>/dev/null || true
            echo "$bashrc_source" >> "$current_bashrc"
            log_success "Added integration to ~/.bashrc"
        fi
    else
        log_info "Manual integration required"
    fi
}

# -----------------------------------------------------------------------------
# Verify Installation
# -----------------------------------------------------------------------------
verify_installation() {
    log_section "Verification"
    
    local all_ok=true
    local files_to_check
    
    if [[ "$INSTALL_MODE" == "native" ]]; then
        files_to_check=(".bashrc" ".bash_aliases" ".bash_functions" ".vimrc" ".tmux.conf")
    else
        files_to_check=("$BASHRC" "$ALIASES" "$FUNCTIONS" "$VIMRC" "$TMUX_CONF")
    fi
    
    for f in "${files_to_check[@]}"; do
        if [[ -f "$HOME/$f" ]]; then
            log_success "Found: ~/$f"
        else
            log_error "Missing: ~/$f"
            all_ok=false
        fi
    done
    
    if [[ "$all_ok" == true ]]; then
        log_success "All configuration files installed successfully"
    else
        log_error "Some files are missing"
        return 1
    fi
}

# -----------------------------------------------------------------------------
# Print Summary
# -----------------------------------------------------------------------------
print_summary() {
    log_section "Installation Complete"
    
    if [[ "$INSTALL_MODE" == "native" ]]; then
        echo "Native installation complete. Files installed:"
        echo "  ~/.bashrc         - Main bash configuration"
        echo "  ~/.bash_aliases   - Command aliases"
        echo "  ~/.bash_functions - Shell functions"
        echo "  ~/.vimrc          - Vim configuration"
        echo "  ~/.tmux.conf      - Tmux configuration"
    else
        echo "Prefix installation complete ($PREFIX). Files installed:"
        echo "  ~/$BASHRC     - Main bash configuration"
        echo "  ~/$ALIASES    - Command aliases"
        echo "  ~/$FUNCTIONS  - Shell functions"
        echo "  ~/$VIMRC      - Vim configuration"
        echo "  ~/$TMUX_CONF  - Tmux configuration"
    fi
    
    echo ""
    echo "To activate now, run:"
    echo -e "  ${CYAN}source ~/.bashrc${RESET}"
    echo ""
    echo "Quick reference:"
    echo "  helpme              - Show function reference"
    echo "  sysinfo             - Display system information"
    echo "  healthcheck         - Quick system health check"
    echo "  vbash/valias/vfunc  - Edit config files"
    echo ""
    
    if [[ -d "$BACKUP_DIR" ]]; then
        echo -e "${YELLOW}Backup location:${RESET} $BACKUP_DIR"
        echo -e "${YELLOW}To restore:${RESET}      $BACKUP_DIR/restore.sh"
        echo ""
    fi
}

# -----------------------------------------------------------------------------
# Uninstall Function
# -----------------------------------------------------------------------------
uninstall() {
    log_section "Uninstall"
    
    echo "Select what to uninstall:"
    echo ""
    echo "  1) Native installation (.bashrc, .vimrc, etc.)"
    echo "  2) Prefix installation (specify prefix)"
    echo ""
    
    read -p "$(echo -e "${CYAN}Select [1/2]:${RESET} ")" -n 1 -r
    echo
    
    case "$REPLY" in
        1)
            local files=(
                "$HOME/.bash_aliases"
                "$HOME/.bash_functions"
            )
            echo ""
            echo -e "${RED}WARNING:${RESET} This will remove .bash_aliases and .bash_functions"
            echo "You should restore .bashrc, .vimrc, .tmux.conf from backup manually"
            echo ""
            if confirm "Remove these files?"; then
                for f in "${files[@]}"; do
                    [[ -f "$f" ]] && rm "$f" && log_success "Removed: $f"
                done
                log_warn "Restore your original .bashrc, .vimrc, .tmux.conf from backup"
            fi
            ;;
        2)
            read -p "$(echo -e "${CYAN}Enter prefix to remove [${DEFAULT_PREFIX}]:${RESET} ")" PREFIX
            PREFIX="${PREFIX:-$DEFAULT_PREFIX}"
            [[ "$PREFIX" != .* ]] && PREFIX=".$PREFIX"
            
            local files=(
                "$HOME/${PREFIX}_bashrc"
                "$HOME/${PREFIX}_aliases"
                "$HOME/${PREFIX}_functions"
                "$HOME/${PREFIX}_vimrc"
                "$HOME/${PREFIX}_tmux.conf"
            )
            
            echo ""
            echo "Files to remove:"
            for f in "${files[@]}"; do
                [[ -f "$f" ]] && echo "  $f"
            done
            echo ""
            
            if confirm "Remove these files?"; then
                for f in "${files[@]}"; do
                    [[ -f "$f" ]] && rm "$f" && log_success "Removed: $f"
                done
                log_warn "Remember to remove the integration block from ~/.bashrc"
            fi
            ;;
        *)
            log_error "Invalid choice"
            ;;
    esac
}

# -----------------------------------------------------------------------------
# Help
# -----------------------------------------------------------------------------
show_help() {
    cat << EOF
Dotfiles Deployment Script

Usage: $0 [command]

Commands:
  install     Install configuration files (default)
  uninstall   Remove configuration files
  help        Show this help message

Installation Modes:
  Native Mode   - Overwrites .bashrc, .vimrc, .tmux.conf directly
                  Best for personal systems where you want standard dotfiles
                  
  Prefix Mode   - Creates separate files (e.g., .dotfiles_bashrc)
                  Best for shared systems or when you need multiple configs
                  Original .bashrc is modified to source the new config

Examples:
  $0              # Interactive installation
  $0 install      # Same as above
  $0 uninstall    # Remove configuration

Notes:
  - Original files are always backed up before modification
  - A restore script is created in the backup directory
  - Native mode uses standard .bash_aliases and .bash_functions
EOF
}

# -----------------------------------------------------------------------------
# Main
# -----------------------------------------------------------------------------
main() {
    echo -e "${BOLD}${CYAN}"
    cat << 'EOF'
    ____        __  _____ __         
   / __ \____  / /_/ __(_) /__  _____
  / / / / __ \/ __/ /_/ / / _ \/ ___/
 / /_/ / /_/ / /_/ __/ / /  __(__  ) 
/_____/\____/\__/_/ /_/_/\___/____/  
                                     
    Deployment Script v2.0
EOF
    echo -e "${RESET}"
    
    local command="${1:-install}"
    
    case "$command" in
        install)
            detect_system
            select_install_mode
            
            if [[ "$INSTALL_MODE" == "native" ]]; then
                configure_native
                backup_existing
                install_native
            else
                configure_prefix
                backup_existing
                install_prefix
                configure_shell_prefix
            fi
            
            verify_installation
            print_summary
            ;;
        uninstall)
            uninstall
            ;;
        help|--help|-h)
            show_help
            ;;
        *)
            log_error "Unknown command: $command"
            show_help
            exit 1
            ;;
    esac
}

main "$@"
