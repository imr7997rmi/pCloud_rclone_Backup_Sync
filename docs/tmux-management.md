# Tmux Session Management Guide

Use tmux to run long backups in background with persistent sessions that can be recovered from any SSH connection.

## Why Tmux Over Screen?

- **Cross-SSH recovery**: Sessions persist and can be accessed from any SSH connection
- **Better session management**: More intuitive commands
- **Modern alternative**: Actively maintained and more stable

## Basic Commands

### Start Session
```bash
ssh user@server
tmux new -s pcloud_backup
./pcloud_backup_interactive.sh
# When backup starts: Ctrl+B, D (detach)
```

### Reconnect from Any SSH Connection
```bash
ssh user@server
tmux attach -s pcloud_backup
```

### Essential Tmux Commands
```bash
tmux ls                           # List all sessions
tmux new -s session_name          # Create named session
tmux attach -s session_name       # Attach to specific session
tmux kill-session -s session_name # Kill specific session
```

## Key Controls (Inside Tmux)
- **Ctrl+B, D**: Detach (keeps running in background)
- **Ctrl+B, C**: Create new window
- **Ctrl+B, &**: Kill current session
- **exit**: Close session normally

## Complete Workflow Example

```bash
# Connect to server
ssh user@your-server

# Start named tmux session
tmux new -s pcloud_backup_2024

# Run backup script  
./pcloud_backup_interactive.sh
# Select folders: 0 2 5
# Confirm: y
# Wait for transfer to start

# Detach from tmux (Ctrl+B, D)
# Close SSH connection - backup continues

# Later, from ANY SSH connection
ssh user@your-server
tmux attach -s pcloud_backup_2024
# View progress
```

## Multiple Backups
```bash
# Start multiple sessions for different backups
tmux new -s backup_documents
tmux new -s backup_photos  
tmux new -s backup_videos

# List all running sessions
tmux ls
```

## Advanced Features

### Session Persistence
- Tmux sessions survive SSH disconnections
- Sessions persist until server reboot or manual termination
- Can be recovered from different computers/networks

### Window Management
```bash
# Inside tmux session:
Ctrl+B, C        # Create new window
Ctrl+B, N        # Next window
Ctrl+B, P        # Previous window
Ctrl+B, 0-9      # Switch to window number
```

## Troubleshooting

### "Session not found"
```bash
# List available sessions
tmux ls

# Check if tmux server is running
ps aux | grep tmux
```

### Multiple Sessions with Same Name
```bash
# Kill specific session
tmux kill-session -s duplicate_name

# Or kill all sessions
tmux kill-server
```

### Permission Issues
```bash
# Check tmux socket permissions
ls -la /tmp/tmux-*
```

## Tips for Long Backups

- **Use descriptive names**: `tmux new -s backup_photos_jan2024`
- **Check progress regularly**: `tmux attach -s session_name`
- **Monitor system resources**: `htop` or `ps aux | grep rclone`
- **Plan for completion**: Set reminders to check backup status

## Tmux vs Screen Quick Reference

| Feature | Tmux | Screen |
|---------|------|--------|
| Detach | Ctrl+B, D | Ctrl+A, D |
| List sessions | `tmux ls` | `screen -ls` |
| Attach | `tmux attach -s name` | `screen -r name` |
| Cross-SSH recovery | ✅ Better | ⚠️ Limited |
| Active development | ✅ Yes | ❌ Minimal |

## Installation

If tmux is not available:
```bash
# Ubuntu/Debian
sudo apt install tmux

# CentOS/RHEL  
sudo yum install tmux

# macOS
brew install tmux
```
