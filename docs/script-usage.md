# Interactive Script Usage Guide

Quick guide for using the pCloud backup script.

## Basic Usage

```bash
./pcloud_backup_interactive.sh
```

## Interactive Process

1. **View folders** - Script shows your pCloud root directories:
```
Carpetas disponibles:
[0] Documents
[1] Photos
[2] Videos
[3] Projects
```

2. **Select folders** - Enter numbers separated by spaces:
```
Introduce numeros (ej: 0 2 5): 0 1 3
```

3. **Confirm and start** - Review selection and confirm:
```
Carpetas seleccionadas:
Documents
Photos  
Projects
Continuar? (y/n): y
```

## Understanding Output

```
Transferred:    45.2M / 45.2M, 100%, 2.1 MB/s, ETA 0s
Checks:         157 / 157, 100%
Transferred:    89 / 89, 100%
✓ Completada: Documents
```

- Shows transfer progress, speed, and completion status
- ✓ = Success, ✗ = Error

## Configuration

### API Rate Limits (Optimized)
Current settings based on community testing:
```bash
--tpslimit 3            # 3 transactions per second (safe limit)
--transfers 6           # 6 parallel file transfers  
--checkers 8            # 8 parallel file checks
--retries 10            # 10 retry attempts
--low-level-retries 100 # 100 connection retries
```

### Change Destination
Edit the script to change backup location:
```bash
DEST_BASE="/your/backup/path"
```

### Adjust Performance
Modify rclone parameters for your needs:
```bash
--tpslimit 2        # API rate limit
--retries 3         # Retry attempts  
--transfers 4       # Parallel transfers
```

## Backup Types

- **Default (sync)**: Mirrors source - deletes files removed from pCloud
- **Archive (copy)**: Never deletes - change `sync` to `copy` in script

## Troubleshooting

- **"No such remote"**: Check `rclone listremotes`
- **Permission errors**: Check destination folder permissions
- **Rate limits**: Increase `--tpslimit` value
