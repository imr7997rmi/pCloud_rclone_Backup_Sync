# Screen Session Management Guide

This guide covers how to use GNU Screen for managing long-running backup processes that can continue even when you disconnect from SSH.

## Why Use Screen?

Screen allows you to:
- **Run processes in background**: Continue execution after disconnecting SSH
- **Resume sessions**: Reconnect to check progress later  
- **Multiple sessions**: Run several backups simultaneously
- **Session persistence**: Survive network interruptions and computer restarts

## Screen Basics

### Key Concepts
- **Session**: A persistent terminal environment that runs in the background
- **Detached**: Session running in background (you're disconnected)
- **Attached**: You're actively connected to the session
- **Screen Name**: Custom identifier for your session

### Essential Commands

#### Session Management
```bash
# Create new named session
screen -S session_name

# List all sessions
screen -ls

# Attach to specific session  
screen -r session_name

# Attach to session by PID
screen -r 12345

# Force attach (disconnect other connections)
screen -d -r session_name

# Kill specific session
screen -S session_name -X quit
```

#### Inside Screen Session
- **Ctrl+A, D**: Detach from session (keeps running)
- **Ctrl+A, K**: Kill current session
- **exit**: Close session normally

## Backup Workflow with Screen

### Standard Workflow

#### Step 1: Connect to NAS
```bash
# SSH to your Synology NAS
ssh -p 44 user@192.168.1.11
```

#### Step 2: Start Screen Session
```bash
# Create named session for backup
screen -S pcloud_backup_interactive
```

#### Step 3: Run Backup Script
```bash
# Execute the interactive script
/volume2/Vault/Isaac/pcloud_backup_interactive.sh
```

#### Step 4: Interact Normally
```
=== BACKUP INTERACTIVO pCloud ===
Carpetas disponibles:
[0] Documents
[1] Photos  
[2] Videos
[3] Projects

Introduce numeros (ej: 0 2 5): 0 1 3
Continuar? (y/n): y
```

#### Step 5: Detach When Transfer Starts
Once large file transfers begin:
```bash
# Press: Ctrl+A, then D
# You'll see: [detached from 12345.pcloud_backup_interactive]
```

#### Step 6: Close SSH/Computer
- Close terminal window
- Shutdown your computer  
- The backup continues running on the NAS

#### Step 7: Reconnect Later
```bash
# SSH back to NAS (hours/days later)
ssh -p 44 user@192.168.1.11

# Reconnect to your backup session
screen -r pcloud_backup_interactive

# View current progress
```

### Advanced Screen Usage

#### Multiple Simultaneous Backups
```bash
# Start first backup
screen -S backup_documents
/volume2/Vault/Isaac/pcloud_backup_interactive.sh
# Select documents folder
# Ctrl+A, D to detach

# Start second backup
screen -S backup_photos  
/volume2/Vault/Isaac/pcloud_backup_interactive.sh
# Select photos folder
# Ctrl+A, D to detach

# Check both sessions
screen -ls
```

#### Managing Multiple Sessions
```bash
# List all active sessions
screen -ls
# Output:
# There are screens on:
#   23043.backup_documents    (Detached)
#   23156.backup_photos       (Detached)
#   23289.backup_videos       (Detached)

# Connect to specific session
screen -r backup_photos

# Kill finished sessions
screen -S backup_documents -X quit
```

### Troubleshooting Screen

#### Common Issues and Solutions

#### "There are several suitable screens"
```bash
# Problem: Multiple sessions with same name
screen -ls
# Output:
# 23043.pcloud_backup_interactive (Detached)  
# 4080.pcloud_backup_interactive  (Detached)

# Solution: Use PID number
screen -r 23043.pcloud_backup_interactive

# Or kill the old one
screen -S 4080.pcloud_backup_interactive -X quit
```

#### "There is a screen on: ... (Attached)"
```bash
# Problem: Session connected elsewhere
screen -r backup_session
# Output: There is a screen on:
#   12345.backup_session (Attached)

# Solution: Force detach and reattach
screen -d -r backup_session
```

#### "Directory /home/user/.screen must have mode 700"
```bash
# Fix screen directory permissions
mkdir -p ~/.screen
chmod 700 ~/.screen

# Alternative: Use temporary directory
export SCREENDIR=/tmp/screen-$USER
mkdir -p $SCREENDIR
chmod 700 $SCREENDIR
```

#### Screen Session Lost After Reboot
```bash
# Screen sessions don't survive system reboots
# Check if any processes are still running
ps aux | grep rclone

# If backup was running, it may have been terminated
# Restart the backup process
```

### Screen Configuration

#### Custom Screen Configuration
Create `~/.screenrc` for persistent settings:
```bash
# Create screen configuration file
cat > ~/.screenrc << 'EOF'
# Increase scrollback buffer
defscrollback 10000

# Show hostname and load in caption
caption always "%{= kw}%-w%{= BW}%n %t%{-}%+w %-= @%H - %LD %d %LM - %c"

# Start with multiple windows
screen -t shell1 0
screen -t shell2 1

# Bind keys for easy window switching
bind j focus down
bind k focus up
bind h focus left  
bind l focus right
EOF
```

#### Session Naming Best Practices
```bash
# Use descriptive names
screen -S pcloud_backup_2024_08_23
screen -S photos_sync_large  
screen -S documents_incremental

# Include date/time for tracking
screen -S backup_$(date +%Y%m%d_%H%M)
```

## Integration with Backup Script

### Enhanced Script with Screen Detection
Add screen detection to your backup script:

```bash
#!/bin/bash
# Check if running in screen
if [ -n "$STY" ]; then
    echo "✓ Running in screen session: $STY"
else
    echo "⚠ Not in screen session - consider using:"
    echo "  screen -S pcloud_backup"
    echo "  $0"
    read -p "Continue anyway? (y/n): " confirm
    [[ $confirm != "y" ]] && exit 1
fi

# Rest of your backup script...
```

### Automatic Session Naming
```bash
#!/bin/bash
# Auto-generate session name with timestamp
SESSION_NAME="pcloud_backup_$(date +%Y%m%d_%H%M)"

# Check if not in screen, offer to start one
if [ -z "$STY" ]; then
    echo "Starting new screen session: $SESSION_NAME"
    screen -S "$SESSION_NAME" "$0"
    exit 0
fi

# Continue with backup logic...
```

## Monitoring and Logging

### Session Monitoring
```bash
# Check session status
screen -ls

# Monitor processes within sessions
screen -S backup_session -X stuff "ps aux | grep rclone\n"

# Send commands to detached session
screen -S backup_session -X stuff "echo 'Status check'\n"
```

### Log Management
```bash
# Enable screen logging
screen -S backup_session -X log

# Logs saved to: screenlog.0, screenlog.1, etc.
tail -f screenlog.0
```

## Best Practices

### Before Starting Backup
1. **Test screen functionality**: `screen -S test` → `Ctrl+A, D` → `screen -r test`
2. **Verify disk space**: `df -h /destination/path`
3. **Check network connectivity**: `ping pcloud.com`
4. **Ensure rclone works**: `rclone lsd pCloud:`

### During Backup
1. **Use descriptive session names**: Include date, purpose
2. **Monitor initial progress**: Stay connected for first few minutes  
3. **Document selections**: Note which folders you selected
4. **Set reminders**: When to check progress

### After Backup
1. **Verify completion**: Check logs for success/error messages
2. **Validate data**: Spot-check transferred files
3. **Clean up sessions**: Kill completed sessions
4. **Document results**: Note transfer times, sizes, issues

### Recovery Procedures
```bash
# If backup seems stuck, check process status
ps aux | grep rclone

# If process died, check system logs
journalctl -f | grep rclone

# Restart backup from screen session
screen -r backup_session
# Ctrl+C to stop current process
./pcloud_backup_interactive.sh
```

## Example Complete Workflow

### Full Backup Session Example
```bash
# 1. SSH to NAS
ssh -p 44 isaacmateo@192.168.1.11

# 2. Check available space
df -h /volume2/Vault/Isaac/

# 3. Start screen with timestamp
screen -S pcloud_backup_$(date +%Y%m%d_%H%M)

# 4. Run backup script
/volume2/Vault/Isaac/pcloud_backup_interactive.sh

# 5. Select folders (e.g., 0 2 5 for Documents, Videos, Archive)
# 6. Confirm selection
# 7. Wait for transfer to start showing progress
# 8. Detach: Ctrl+A, D

# 9. Hours later, reconnect
ssh -p 44 isaacmateo@192.168.1.11
screen -ls
screen -r pcloud_backup_20240823_1430

# 10. Check results and clean up
# If completed: Ctrl+A, K or exit
```

This workflow ensures your backups can run uninterrupted regardless of local computer issues or network disconnections.
