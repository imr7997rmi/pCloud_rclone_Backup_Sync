# rclone Remote Configuration Guide

This guide covers how to configure rclone with pCloud for backup operations.

## Method 1: Direct Configuration on NAS (SSH Access)

### Step 1: Install rclone on Synology NAS

#### Option A: Using SynoCommunity Package
1. Add SynoCommunity to Package Center:
   - Package Center → Settings → Package Sources
   - Add: `https://packages.synocommunity.com/`
2. Install "rclone" package from Community tab

#### Option B: Manual Installation
```bash
# Download rclone for your architecture
curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip
unzip rclone-current-linux-amd64.zip
sudo cp rclone-v*/rclone /usr/local/bin/
rm -rf rclone-v* rclone-current-linux-amd64.zip
```

### Step 2: Configure pCloud Remote
```bash
# Start rclone configuration
rclone config

# Follow these steps:
# n) New remote
# name> pCloud
# Choose: 24 (pCloud)
# client_id> (press Enter for default)
# client_secret> (press Enter for default)
# Use auto config? y
```

**Note**: Auto config requires browser access. If SSH-only, see Method 2 below.

### Step 3: Verify Configuration
```bash
# Test the connection
rclone lsd pCloud:

# Should list your pCloud root folders
```

## Method 2: Configuration via Another Machine with Browser

### When to Use This Method
- NAS has no GUI browser access
- SSH-only environment
- Headless server setup

### Step 1: Install rclone on Helper Machine

#### macOS
```bash
brew install rclone
```

#### Windows
Download from https://rclone.org/downloads/

#### Linux
```bash
curl https://rclone.org/install.sh | sudo bash
```

### Step 2: Configure on Helper Machine
```bash
# Start configuration
rclone config

# Create new remote
# n) New remote
# name> pCloud
# Choose: 24 (pCloud)
# client_id> (press Enter)
# client_secret> (press Enter)
# Use auto config? y

# Browser will open for pCloud authentication
# Login and authorize rclone
```

### Step 3: Extract Configuration
```bash
# Show the configuration
rclone config show pCloud

# Output will be something like:
# [pCloud]
# type = pcloud
# token = {"access_token":"xyz123...","token_type":"bearer","refresh_token":"abc456..."}
```

### Step 4: Transfer to NAS
Copy the configuration to your NAS using one of these methods:

#### Method A: Manual Config File Creation
```bash
# SSH to your NAS
ssh -p 22 user@nas-ip

# Create rclone config directory
mkdir -p ~/.config/rclone

# Create config file
nano ~/.config/rclone/rclone.conf

# Paste the configuration:
[pCloud]
type = pcloud
token = {"access_token":"xyz123...","token_type":"bearer","refresh_token":"abc456..."}
```

#### Method B: SCP Transfer
```bash
# From helper machine, copy config file
scp ~/.config/rclone/rclone.conf user@nas-ip:~/.config/rclone/
```

### Step 5: Test on NAS
```bash
# SSH to NAS and test
rclone lsd pCloud:
```

## Method 3: Terminal-Only Authentication

### Step 1: Configure with Remote Authorization
```bash
# On NAS, start config
rclone config

# n) New remote
# name> pCloud
# Choose: 24 (pCloud)
# client_id> (press Enter)
# client_secret> (press Enter)
# Use auto config? n

# Copy the authorization URL shown
# Open URL on any device with browser
# Complete authorization
# Copy the verification code back to terminal
```

## Common Configuration Options

### Rate Limiting
Add to your remote configuration:
```ini
[pCloud]
type = pcloud
token = {...}
# Add these for better performance
tpslimit = 2
checkers = 4
transfers = 2
```

### Advanced Options
```bash
# Test bandwidth
rclone config reconnect pCloud:

# Check quota
rclone about pCloud:

# List remote contents with details
rclone lsl pCloud: --max-depth 1
```

## Troubleshooting

### Token Expiration
```bash
# Refresh expired tokens
rclone config reconnect pCloud:
```

### Connection Issues
```bash
# Test connectivity
rclone lsd pCloud: --verbose

# Debug connection
rclone lsd pCloud: --log-level DEBUG
```

### Permission Errors
```bash
# Ensure proper ownership
chown -R $(whoami) ~/.config/rclone/
chmod 600 ~/.config/rclone/rclone.conf
```

## Example pCloud Remote Names

After configuration, your remote will be accessible as:
- `pCloud:` - Root of pCloud
- `pCloud:/Documents` - Documents folder
- `pCloud:/Photos` - Photos folder

## Security Notes

- Keep your rclone.conf file secure (600 permissions)
- Regularly rotate access tokens
- Use application-specific passwords when possible
- Don't share configuration files containing tokens

## Next Steps

Once configured, proceed to:
- [Script Usage Guide](script-usage.md)
- [Screen Session Management](screen-management.md)
