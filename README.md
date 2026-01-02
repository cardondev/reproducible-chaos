# Getting Started

Everything you need to know to get up and running with these dotfiles.

---

## Installation

### Download and Extract

```bash
# Download the tarball
# Then extract it
tar xzf dotfiles.tar.gz
cd dotfiles
```

### Run the Installer

```bash
chmod +x deploy.sh
./deploy.sh
```

### Choose Installation Mode

You'll be prompted to choose:

**Option 1: Native Mode**
- Directly replaces your `.bashrc`, `.vimrc`, `.tmux.conf`
- Uses standard `.bash_aliases` and `.bash_functions`
- Best for personal systems
- Original files are backed up

**Option 2: Prefix Mode**
- Creates separate files (e.g., `.cardondev_bashrc`)
- Only adds a sourcing line to your existing `.bashrc`
- Best for shared systems or testing
- Allows multiple configurations

### Activate

```bash
source ~/.bashrc
```

---

## The Prompt

Your new prompt looks like this:

```
═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-═-
┌─[14:30:22 EST]─[Wednesday, January 15, 2025]─[user@hostname]
├─[~/projects/mystuff]
└─❯❯❯ 
```

**As root:**
```
└─⚡❯❯❯ 
```

**After a command fails:**
```
└─[!1]❯❯❯ 
```

> **PuTTY Users:** The prompt automatically uses ASCII characters if Unicode isn't supported.

---

## First Commands to Try

### Check System Status

```bash
# Comprehensive system info
sysinfo

# Quick health check
healthcheck
```

### Get Help

```bash
# Function reference
helpme

# See all aliases
alias
```

### Navigate Quickly

```bash
# Go up directories
..      # One level
...     # Two levels
....    # Three levels

# Go home
~

# Go back
-
```

---

## Essential Aliases

### What You'll Use Daily

| Old Way | New Way | What It Does |
|---------|---------|--------------|
| `ls -la` | `ll` | Long list with details |
| `systemctl status nginx` | `sts nginx` | Check service |
| `systemctl restart nginx` | `srs nginx` | Restart service |
| `journalctl -u nginx -f` | `slog nginx` | Follow logs |
| `vim ~/.bashrc` | `vbash` | Edit bash config |
| `source ~/.bashrc` | `reload` | Reload config |

### Service Management

```bash
# Check a service
sts httpd

# Start and enable
srt httpd
sen httpd

# See what's wrong
sfailed
```

### Finding Things

```bash
# Find files
ff "*.conf"

# Find text in files
ftext "error"

# Find large files
bigfiles 100M
```

---

## Working with Tmux

### Start a Session

```bash
# New session
tmux

# Named session (better)
tn work
```

### Essential Keys

Remember: Prefix is `Ctrl+a`

| Action | Keys |
|--------|------|
| Split vertical | `Ctrl+a |` |
| Split horizontal | `Ctrl+a -` |
| Navigate panes | `Alt + Arrow` |
| New window | `Ctrl+a c` |
| Next window | `Shift + Right` |
| Detach | `Ctrl+a d` |

### Reattach Later

```bash
# List sessions
tl

# Attach
ta work
```

---

## Using Vim

### Basic Workflow

```bash
vim mystuff.txt
```

1. Press `i` to enter insert mode
2. Type your text
3. Press `jk` (or Escape) to exit insert mode
4. Press `Space w` to save
5. Press `Space q` to quit

### Quick Reference

| Action | Keys |
|--------|------|
| Save | `Space w` |
| Quit | `Space q` |
| Save & Quit | `Space x` |
| Search | `/pattern` |
| Clear search | `Space Space` |
| File browser | `Space e` |

---

## Customization

### Edit Configs

```bash
vbash     # Main shell config
valias    # Aliases
vfunc     # Functions
vvim      # Vim config
vtmux     # Tmux config
```

### Reload After Changes

```bash
# Shell config
reload
# or
dotfiles_update

# Vim (inside vim)
:source %

# Tmux (inside tmux)
Ctrl+a r
```

---

## Disable Welcome Screen

If you don't want the startup message:

```bash
# Add to your .bashrc (before sourcing dotfiles)
export DOTFILES_NO_WELCOME=1
```

---

## Force ASCII Mode

For terminals without Unicode support:

```bash
# Add to your .bashrc
export TERM_HAS_UNICODE=0
```

---

## Backup and Restore

### Your Backups

When you installed, your original files were backed up to:
```
~/.dotfiles_backup_YYYYMMDDHHMMSS/
```

### Restore Original

```bash
~/.dotfiles_backup_YYYYMMDDHHMMSS/restore.sh
source ~/.bashrc
```

### Backup Current Config

```bash
dotfiles_backup
```

---

## Troubleshooting

### Colors Not Working

```bash
# Check terminal type
echo $TERM

# Should be xterm-256color or similar
# If not, add to .bashrc:
export TERM=xterm-256color
```

### Prompt Characters Broken

```bash
# Force ASCII mode
export TERM_HAS_UNICODE=0
source ~/.bashrc
```

### Tmux Colors Wrong

```bash
# Start tmux with 256 colors
tmux -2
```

### Alias Not Found

```bash
# Reload configuration
reload

# Check if alias exists
alias | grep myalias
```

---

## Cheat Sheet

```
NAVIGATION
  ..        Up one          ll        Long list
  ...       Up two          ~         Home
  -         Previous dir    c         Clear

SERVICES
  sts name  Status          srs name  Restart
  srt name  Start           stp name  Stop
  sen name  Enable          sdi name  Disable

SYSTEM
  sysinfo      Full system info
  healthcheck  Quick health audit
  helpme       Function reference

LOGS
  logs         System logs     syslog    Follow messages
  authlog      Follow secure   errorlog  Recent errors

EDIT CONFIG
  vbash   bashrc    valias   aliases
  vfunc   functions vvim     vimrc
  vtmux   tmux      reload   Apply changes

TMUX (Prefix = Ctrl+a)
  |       Split vert      -         Split horiz
  hjkl    Navigate        d         Detach
  c       New window      Shift+←→  Switch window

VIM (Leader = Space)
  w       Save            q         Quit
  e       File browser    Space     Clear search
  v       Vsplit          s         Hsplit
```

---
