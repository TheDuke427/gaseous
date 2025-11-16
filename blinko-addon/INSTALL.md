# Installation Guide

This guide will walk you through installing the Blinko add-on for Home Assistant.

## Prerequisites

- Home Assistant OS or Supervised installation
- At least 4GB RAM recommended
- 2GB+ free disk space
- Docker support (included in Home Assistant OS/Supervised)

## Method 1: Install from GitHub Repository (Recommended for Testing)

### Step 1: Add the Repository

1. Open Home Assistant
2. Navigate to **Settings** → **Add-ons**
3. Click the **Add-on Store** button (bottom right)
4. Click the **three dots menu** (⋮) in the top right
5. Select **Repositories**
6. Add this repository URL:
   ```
   https://github.com/YOUR_USERNAME/homeassistant-blinko-addon
   ```
7. Click **Add**

### Step 2: Install the Add-on

1. Refresh the Add-on Store page
2. Find "Blinko" in the list
3. Click on it
4. Click **Install**
5. Wait for installation to complete (this may take several minutes)

### Step 3: Configure the Add-on

⚠️ **IMPORTANT**: You must configure the add-on before starting it!

1. Go to the **Configuration** tab
2. Change the default passwords:

```yaml
postgres_password: "YOUR_SECURE_PASSWORD_HERE"
nextauth_secret: "YOUR_LONG_RANDOM_SECRET_KEY_AT_LEAST_32_CHARACTERS"
timezone: "Your/Timezone"
```

**Generate secure passwords:**

For `nextauth_secret`, you can use:
```bash
openssl rand -base64 32
```

Or use a password manager to generate a 32+ character random string.

### Step 4: Start the Add-on

1. Go to the **Info** tab
2. Enable **Start on boot** (optional but recommended)
3. Enable **Show in sidebar** (for easy Ingress access)
4. Click **Start**
5. Monitor the **Log** tab for any errors

### Step 5: Access Blinko

**Via Ingress (Recommended):**
- Click on **Blinko** in your Home Assistant sidebar

**Via Direct Port (Optional):**
- Access `http://YOUR_HOME_ASSISTANT_IP:1111`

## Method 2: Local Development Installation

If you want to develop or test the add-on locally:

### Step 1: Copy Add-on Files

1. Connect to your Home Assistant instance (SSH, Samba, or SFTP)
2. Navigate to `/addons/` directory
3. Create a new directory: `mkdir /addons/blinko`
4. Copy all files from this repository to `/addons/blinko/`

### Step 2: Install from Local Add-ons

1. In Home Assistant, go to **Settings** → **Add-ons**
2. Click **Add-on Store**
3. Refresh the page
4. Look for "Local add-ons" section
5. Find "Blinko" and click it
6. Click **Install**
7. Follow Steps 3-5 from Method 1

## Post-Installation Setup

### First Login

1. Access Blinko (via Ingress or direct URL)
2. Create your first user account
3. Set your username and password
4. Log in with your new credentials

### Configure AI Features (Optional)

If you want to use AI-powered search:

1. Log in to Blinko
2. Go to Settings
3. Configure AI provider (OpenAI, Ollama, etc.)
4. Enter API keys if using external services

### Mobile Access

To access from mobile:

1. Install the Home Assistant mobile app
2. Log in to your Home Assistant instance
3. Navigate to the sidebar menu
4. Tap on "Blinko"
5. (Optional) Add to home screen for quick access

## Troubleshooting Installation

### Add-on Won't Install

**Problem**: Installation fails or times out

**Solutions**:
1. Check internet connection
2. Verify sufficient disk space (2GB+)
3. Check Home Assistant logs
4. Try restarting Home Assistant

### Add-on Won't Start

**Problem**: Add-on starts then immediately stops

**Solutions**:
1. Check you've changed both default passwords
2. Verify `nextauth_secret` is at least 32 characters
3. Check add-on logs for specific errors
4. Ensure sufficient RAM (4GB+ recommended)

### Can't Find Add-on in Store

**Problem**: Blinko doesn't appear after adding repository

**Solutions**:
1. Refresh the Add-on Store page
2. Check the repository URL is correct
3. Verify repository was added successfully
4. Restart Home Assistant if necessary

### Docker Socket Errors

**Problem**: Errors about Docker socket or permissions

**Solutions**:
1. This add-on requires Docker-in-Docker
2. Ensure you're running Home Assistant OS or Supervised
3. Container installation is not supported
4. Check system logs for Docker issues

## Updating the Add-on

When updates are available:

1. Go to **Settings** → **Add-ons**
2. Click on **Blinko**
3. If an update is available, you'll see an **Update** button
4. Click **Update** and wait for completion
5. Restart the add-on

Your data and configuration will be preserved during updates.

## Uninstalling

To remove the add-on:

1. Stop the add-on
2. Click **Uninstall**
3. Confirm the action

⚠️ **Warning**: Uninstalling will delete all Blinko data including notes and database. Make sure to backup first!

## Backup and Restore

### Automatic Backup (Recommended)

1. Use Home Assistant's built-in backup feature
2. Go to **Settings** → **System** → **Backups**
3. Create a backup (will include all add-on data)

### Manual Backup

If you need to manually backup Blinko data:

1. Connect to your Home Assistant instance via SSH
2. Backup these directories:
   ```bash
   /data/blinko/
   /data/postgres/
   ```
3. Store the backup in a safe location

### Restore from Backup

1. Restore Home Assistant backup that includes the add-on
2. Or manually copy backed-up directories back to their original locations
3. Restart the add-on

## Support

If you encounter issues:

- Check the [README.md](README.md) for configuration help
- Review [DOCS.md](DOCS.md) for detailed documentation
- Search [Blinko GitHub Issues](https://github.com/blinkospace/blinko/issues)
- Post on Home Assistant Community Forums
- Include logs when reporting issues (remove passwords!)

## Next Steps

After successful installation:

1. Create your first note
2. Explore Markdown formatting
3. Set up tags for organization
4. Configure AI features (optional)
5. Set up mobile access
6. Create regular backups

Enjoy using Blinko! 🎉
