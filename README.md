# Reproducible Chaos Dotfiles 
![RHEL](https://img.shields.io/badge/RHEL-compatible-red)
![Fedora](https://img.shields.io/badge/Fedora-compatible-blue)
![Rocky Linux](https://img.shields.io/badge/Rocky%20Linux-compatible-green)
![AlmaLinux](https://img.shields.io/badge/AlmaLinux-compatible-purple)

## Compatible Distros
  - Red Hat Enterprise Linux
  - Rocky Linux
  - AlmaLinux
  - Fedora
    
> [!NOTE]
> This might work on Ubuntu based distros, but it is not officially supported.

## Features

- **PuTTY Compatible**: ASCII fallback for terminals without Unicode support
- **Theme**: ![Catppuccin Mocha](https://img.shields.io/badge/Catppuccin-Mocha-1e1e2e)
- **RHEL Optimized**: Aliases and functions tailored for EL based distros
- **Dual Installation Modes**: Native overwrite or prefix based installation
- **Safe Deployment**: Backs up existing configurations with restore script
- **Modular Design**: Easy to customize and extend
- **No External Dependencies**: Uses only bash, vim, tmux, and standard RHEL tools

## File Structure

```
dotfiles/
├── deploy.sh       # Installation script
├── bashrc          # Main bash configuration
├── aliases         # Command aliases
├── functions       # Shell functions
├── vimrc           # Vim configuration
├── tmux.conf       # Tmux configuration
└── README.md       # This file
```

## Installation

### Quick Install

```bash
chmod +x deploy.sh
./deploy.sh
```

### Installation Modes

The deployment script offers two modes:

#### Native Mode (Recommended for personal systems)
- Directly overwrites `.bashrc`, `.vimrc`, `.tmux.conf`
- Uses standard `.bash_aliases` and `.bash_functions`
- Original files are backed up with a restore script
- Works like any normal dotfiles setup

#### Prefix Mode (Recommended for shared/managed systems)
- Creates separate files like `.dotfiles_bashrc`
- Original `.bashrc` is preserved (only adds sourcing line)
- Allows multiple configurations on the same system
- Good for testing without affecting existing setup

### Restoring Original Configuration

If you used native mode and want to restore your original dotfiles:

```bash
# The backup location is shown after installation
~/.dotfiles_backup_YYYYMMDDHHMMSS/restore.sh
```

### Manual Install (Prefix Mode)

1. Copy files to home directory with your chosen prefix:
   ```bash
   cp bashrc ~/.myprefix_bashrc
   cp aliases ~/.myprefix_aliases
   cp functions ~/.myprefix_functions
   cp vimrc ~/.myprefix_vimrc
   cp tmux.conf ~/.myprefix_tmux.conf
   ```

2. Add to `~/.bashrc`:
   ```bash
   export DOTFILES_PREFIX=".myprefix"
   if [[ -f "$HOME/.myprefix_bashrc" ]]; then
       source "$HOME/.myprefix_bashrc"
   fi
   ```

3. Reload shell:
   ```bash
   source ~/.bashrc
   ```

## Prompt Format

The prompt adapts to terminal capabilities:

**Unicode Terminals (Windows Terminal, modern xterm)**:
```
┌─[16:20:34 EST]─[Wednesday, December 31, 2025]─[user@hostname]
├─[~/projects]
└─❯❯❯ 
```

**Root User**:
```
┌─[16:20:34 EST]─[Wednesday, December 31, 2025]─[root@hostname]
├─[/etc]
└─⚡❯❯❯ 
```

**ASCII Fallback (PuTTY)**:
```
+-[16:20:34 EST]-[Wednesday, December 31, 2025]-[user@hostname]
|-[~/projects]
+->>> 
```

## Key Aliases

### Navigation
| Alias | Command |
|-------|---------|
| `..` | `cd ..` |
| `...` | `cd ../..` |
| `ll` | `ls -lAhF --group-directories-first` |

### Systemd Services
| Alias | Command |
|-------|---------|
| `sts` | `systemctl status` |
| `srt` | `sudo systemctl start` |
| `stp` | `sudo systemctl stop` |
| `srs` | `sudo systemctl restart` |
| `sfailed` | `systemctl --failed` |

### Package Management
| Alias | Command |
|-------|---------|
| `update` | `sudo dnf update -y` |
| `install` | `sudo dnf install -y` |
| `search` | `dnf search` |

### Logs
| Alias | Command |
|-------|---------|
| `logs` | `sudo journalctl -xe` |
| `syslog` | `sudo tail -f /var/log/messages` |
| `authlog` | `sudo tail -f /var/log/secure` |

### SELinux
| Alias | Command |
|-------|---------|
| `sestat` | `getenforce` |
| `secontext` | `ls -laZ` |
| `seaudit` | `sudo ausearch -m AVC -ts recent` |

## Key Functions

| Function | Description |
|----------|-------------|
| `sysinfo` | Display system information |
| `healthcheck` | Quick system health check |
| `svc <name> <action>` | Service management helper |
| `mkcd <dir>` | Create and enter directory |
| `mkbak <file>` | Create timestamped backup |
| `extract <archive>` | Extract any archive type |
| `ff <pattern>` | Find files by name |
| `ftext <pattern>` | Search file contents |
| `portcheck <host> [port]` | Check if port is open |
| `usercheck <user>` | Display user information |
| `logsearch <pattern>` | Search logs for pattern |
| `errorlog [n]` | Show recent errors |
| `helpme` | Show function reference |

## Vim Shortcuts

| Key | Action |
|-----|--------|
| `Space` | Leader key |
| `Space w` | Save |
| `Space q` | Quit |
| `Space e` | File browser (netrw) |
| `Space Space` | Clear search highlight |
| `Space v` | Vertical split |
| `Space s` | Horizontal split |
| `jk` | Escape (insert mode) |
| `Tab` | Next tab |
| `Shift-Tab` | Previous tab |

## Tmux Shortcuts

| Key | Action |
|-----|--------|
| `Ctrl-a` | Prefix (instead of Ctrl-b) |
| `Prefix \|` | Vertical split |
| `Prefix -` | Horizontal split |
| `Prefix r` | Reload config |
| `Prefix y` | Toggle sync panes |
| `Prefix h/j/k/l` | Navigate panes (vim-style) |
| `Alt-Arrow` | Navigate panes (no prefix) |
| `Shift-Left/Right` | Navigate windows |

## Customization

### Disable Welcome Message
```bash
export DOTFILES_NO_WELCOME=1
```

### Force Unicode/ASCII Mode
```bash
export TERM_HAS_UNICODE=1  # Force Unicode
export TERM_HAS_UNICODE=0  # Force ASCII
```

### Edit Configuration
```bash
vbash    # Edit bashrc
valias   # Edit aliases
vfunc    # Edit functions
vvim     # Edit vimrc
vtmux    # Edit tmux.conf
```

## Uninstallation

```bash
./deploy.sh uninstall
```

Or manually remove files and the integration block from `~/.bashrc`.

## Compatibility

- **Operating Systems**: RHEL 7, RHEL 8, RHEL 9, CentOS 7+, Rocky Linux, AlmaLinux
- **Terminals**: PuTTY, SuperPuTTY, Windows Terminal, xterm, gnome-terminal
- **Bash Version**: 4.0+ (3.2 with reduced features)
- **Tmux Version**: 2.1+
- **Vim Version**: 7.4+

## Troubleshooting

### Prompt characters not displaying correctly
Set ASCII mode:
```bash
export TERM_HAS_UNICODE=0
source ~/.bashrc
```

### Colors not working
Ensure 256-color support:
```bash
export TERM=xterm-256color
```

### Tmux colors wrong
Use screen-256color in tmux:
```bash
tmux -2  # Force 256 colors
```
