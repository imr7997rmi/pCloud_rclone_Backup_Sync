# Screen Session Management Guide

Use screen to run long backups in background, even when disconnected.

## Basic Commands

### Start Session
```bash
ssh user@server
screen -S backup_session
./pcloud_backup_interactive.sh
# When backup starts: Ctrl+A, D (detach)
```

### Reconnect Later  
```bash
ssh user@server
screen -r backup_session
```

### Manage Sessions
```bash
screen -ls                    # List sessions
screen -r session_name        # Reconnect to specific session
screen -S old_session -X quit # Kill session
```

## Key Controls (Inside Screen)
- **Ctrl+A, D**: Detach (keeps running in background)
- **Ctrl+A, K**: Kill session completely  
- **exit**: Close session normally

## Complete Workflow Example

```bash
# Connect to server
ssh user@your-server

# Start named screen session
screen -S pcloud_backup

# Run backup script  
./pcloud_backup_interactive.sh
# Select folders: 0 2 5
# Confirm: y
# Wait for transfer to start

# Detach from screen (Ctrl+A, D)
# Close SSH connection - backup continues

# Later, reconnect
ssh user@your-server
screen -r pcloud_backup
# View progress
```

## Multiple Backups
```bash
# Start multiple sessions
screen -S backup_docs
screen -S backup_photos
screen -S backup_videos

# Check all sessions
screen -ls
```

## Troubleshooting

### "Several suitable screens"
```bash
# Use PID number
screen -r 12345.backup_session
```

### "Screen is Attached"
```bash
# Force detach and reattach
screen -d -r backup_session  
```

### Permission Error
```bash
mkdir -p ~/.screen
chmod 700 ~/.screen
```

## Tips
- Use descriptive session names: `backup_photos_2024`
- Stay connected initially to verify backup starts
- Screen sessions don't survive server reboots
- Check running processes: `ps aux | grep rclone`
