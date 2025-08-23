# pCloud Remote Configuration Guide

Quick guide to configure rclone with pCloud (Provider #42).

## Install rclone

**Linux:**
```bash
curl https://rclone.org/install.sh | sudo bash
```

**Synology NAS:**
- Add SynoCommunity: `https://packages.synocommunity.com/`
- Install rclone from Community packages

## Configure pCloud Remote

### Method 1: With Browser Access
```bash
rclone config
n) New remote
name> pCloud
Type of storage> 42
client_id> [Enter]
client_secret> [Enter] 
Use auto config? y
```
Browser opens → Login to pCloud → Complete 2FA if enabled → Authorize

### Method 2: Headless (No Browser)
```bash
rclone config
n) New remote
name> pCloud
Type of storage> 42
client_id> [Enter]
client_secret> [Enter]
Use auto config? n
```
Copy the authorization URL → Open on phone/computer → Login → Complete 2FA → Copy verification code back to terminal

### Method 3: Configure on Another Machine
1. Configure on computer with browser (Method 1)
2. Copy token from `rclone config show pCloud`
3. Create `~/.config/rclone/rclone.conf` on target system:
```ini
[pCloud]
type = pcloud
token = {"access_token":"xxxxx","token_type":"bearer","refresh_token":"yyyyy"}
```

## Test Configuration
```bash
rclone lsd pCloud:
```
Should list your pCloud folders.

## 2FA Notes
- Works with all methods
- Complete 2FA challenge during browser authorization
- Keep 2FA app time synchronized

## Troubleshooting
- Update rclone if provider #42 not found: `rclone selfupdate`
- Fix permissions: `chmod 600 ~/.config/rclone/rclone.conf`
- Refresh tokens: `rclone config reconnect pCloud:`
