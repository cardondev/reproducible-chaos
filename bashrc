#!/bin/bash
# =============================================================================
# BASHRC - Main Shell Configuration
# Theme: Catppuccin Mocha
# Compatible: RHEL 7+, PuTTY, Windows Terminal, xterm
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

# Custom config locations (set by deploy script)
export DOTFILES_PREFIX="${DOTFILES_PREFIX:-.dotfiles}"
export VIMINIT='let $MYVIMRC="$HOME/'"${DOTFILES_PREFIX}"'_vimrc" | source $MYVIMRC'

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

# Semantic colors
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
[[ -f "$HOME/${DOTFILES_PREFIX}_aliases" ]] && . "$HOME/${DOTFILES_PREFIX}_aliases"
[[ -f "$HOME/${DOTFILES_PREFIX}_functions" ]] && . "$HOME/${DOTFILES_PREFIX}_functions"

# -----------------------------------------------------------------------------
# Welcome Message (optional, can be disabled)
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
