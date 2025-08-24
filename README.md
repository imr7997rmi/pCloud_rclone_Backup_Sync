# pCloud rclone Backup & Sync

Interactive backup script for pCloud to Synology NAS using rclone with screen session management for long-running tasks.

## Features

- Interactive folder selection from pCloud root directories
- **Optimized API rate limits**: 6 parallel transfers, enhanced retry logic
- Incremental backup (only syncs new/modified files)
- **Tmux session support** for background execution and session persistence
- Progress monitoring with human-readable MB/GB units
- Optimized for large files with intelligent rate limiting

## Prerequisites

- Synology NAS with DSM 6.x or 7.x
- SSH access enabled
- rclone installed and configured
- pCloud remote configured in rclone

## Installation

1. Clone this repository to your NAS:
```bash
git clone https://github.com/imr7997rmi/pCloud_rclone_Backup_Sync.git
cd pCloud_rclone_Backup_Sync
```

2. Make the script executable:
```bash
chmod +x pcloud_backup_interactive.sh
```

3. Edit the script to configure your pCloud remote:
```bash
nano pcloud_backup_interactive.sh
```
Update the REMOTE variable with your configured pCloud remote name.

## Usage

### Quick Start
```bash
./pcloud_backup_interactive.sh
```

### With Tmux Session (Recommended for large backups)
```bash
# Start tmux session
tmux new -s pcloud_backup

# Run the script
./pcloud_backup_interactive.sh

# Detach from tmux (keeps running in background)
# Press: Ctrl+B, then D

# Reattach later to check progress
tmux attach -s pcloud_backup
```

## Documentation

- [rclone Remote Configuration Guide](docs/rclone-setup.md)
- [Interactive Script Usage](docs/script-usage.md) 
- [Tmux Session Management](docs/tmux-management.md)

## File Structure

```
pCloud_rclone_Backup_Sync/
├── pcloud_backup_interactive.sh    # Main backup script
├── docs/                          # Documentation
│   ├── rclone-setup.md           # rclone configuration guide
│   ├── script-usage.md           # Script usage instructions
│   └── tmux-management.md        # Tmux session guide
└── README.md                     # This file
```

## Contributing

1. Fork this repository
2. Create a feature branch
3. Commit your changes
4. Push to the branch
5. Create a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

If you encounter any issues, please open an issue on GitHub.
