# Installation Guide for Blinko Home Assistant Add-on

This guide will walk you through the complete installation process.

## Prerequisites

- Home Assistant OS, Supervised, or Container installation
- At least 1GB of free disk space
- Internet connection to download Docker images

## Step 1: Add the Repository

### Method A: Via Home Assistant UI

1. Open Home Assistant in your browser
2. Navigate to **Settings** → **Add-ons**
3. Click on **Add-on Store** (bottom right)
4. Click the **⋮** (three dots) menu in the top right corner
5. Select **Repositories**
6. Add the repository URL: `https://github.com/YOUR_USERNAME/hassio-addons-blinko`
7. Click **Add**
8. Click **Close**

### Method B: Via Configuration File (Advanced)

Add this to your `/config/configuration.yaml`:

```yaml
hassio:
```

Then manually add the repository through the Supervisor API.

## Step 2: Install the Add-on

1. Refresh the Add-on Store page
2. Find **Blinko** in the list of available add-ons
3. Click on **Blinko**
4. Click **Install**
5. Wait for the installation to complete (this may take several minutes)

## Step 3: Configure the Add-on

Before starting the add-on, you **must** configure it:

1. Click on the **Configuration** tab
2. Generate secure secrets (see below)
3. Update the configuration:

```yaml
postgres_password: "YOUR_GENERATED_PASSWORD"
nextauth_secret: "YOUR_GENERATED_SECRET"
```

### Generating Secure Secrets

Use one of these methods to generate secure values:

**On Linux/Mac:**
```bash
openssl rand -base64 32
```

**On Windows (PowerShell):**
```powershell
[Convert]::ToBase64String([System.Security.Cryptography.RandomNumberGenerator]::GetBytes(32))
```

**Online (use a password generator):**
- LastPass Password Generator
- 1Password Password Generator
- Strong Random Password Generator

Generate **two different** values:
- One for `postgres_password`
- One for `nextauth_secret`

### Example Configuration

```yaml
postgres_password: "xK9mP2vR8nQ4wE7tY1uI5oL3aS6dF0gH"
nextauth_secret: "A7sD9fG2hJ4kL6pQ8wE1rT3yU5iO7aS9"
```

4. Click **Save**

## Step 4: Start the Add-on

1. Navigate to the **Info** tab
2. Toggle **Start on boot** (recommended)
3. Click **Start**
4. Monitor the **Log** tab for startup progress

You should see messages like:
```
[INFO] Starting Blinko add-on...
[INFO] Starting Blinko services...
[INFO] Blinko is now running!
```

## Step 5: Access Blinko

### Via Ingress (Recommended)

1. Look for **Blinko** in your Home Assistant sidebar
2. Click on it to open Blinko

### Via Direct URL (Alternative)

If not using ingress, access at:
```
http://YOUR_HOME_ASSISTANT_IP:1111
```

## Step 6: First Login

1. Use the default credentials:
   - Username: `blinko`
   - Password: `blinko`

2. **Immediately after logging in:**
   - Click on your profile/settings
   - Change your password to something secure
   - Update your profile information

## Verification

To verify everything is working:

1. Create a test note
2. Try the search function
3. Add some tags
4. Check that notes are saved and persisting

## Troubleshooting Installation

### Add-on Won't Start

**Check the logs:**
1. Go to the **Log** tab
2. Look for error messages

**Common issues:**
- Invalid configuration (check your YAML syntax)
- Ports already in use (check if port 1111 is available)
- Insufficient resources (check system resources)

### Can't Find the Repository

- Verify the repository URL is correct
- Check your internet connection
- Try refreshing the Add-on Store page
- Clear your browser cache

### Add-on Installs but Shows Errors

1. Check the installation logs
2. Verify you have enough disk space: **Settings** → **System** → **Storage**
3. Try uninstalling and reinstalling
4. Check Home Assistant logs: **Settings** → **System** → **Logs**

### Database Connection Errors

1. Stop the add-on
2. Wait 30 seconds
3. Start the add-on again
4. Check logs for PostgreSQL health check messages

### Can't Access via Ingress

1. Ensure the add-on status shows **Running**
2. Refresh your browser (hard refresh: Ctrl+Shift+R or Cmd+Shift+R)
3. Try a different browser
4. Check if Home Assistant itself is accessible
5. Review Home Assistant ingress logs

## Post-Installation Steps

### 1. Create a Backup

After successful installation:
1. Go to **Settings** → **System** → **Backups**
2. Create a **Full Backup** or **Partial Backup** (include add-ons)

### 2. Set Up Automation (Optional)

Create automations to send notes to Blinko:
```yaml
automation:
  - alias: "Add reminder to Blinko"
    trigger:
      platform: event
      event_type: my_event
    action:
      service: rest_command.blinko_add_note
      data:
        message: "{{ trigger.event.data.message }}"
```

### 3. Configure AI Features (Optional)

If you want to use AI-powered features:
1. Open Blinko settings
2. Configure OpenAI API key or Ollama endpoint
3. Test the AI search functionality

### 4. Mobile Access

To access from mobile:
1. Ensure Home Assistant is accessible from mobile (via Nabu Casa or custom setup)
2. Open Home Assistant app
3. Navigate to Blinko in the sidebar

## Updating

When updates are available:

1. Go to **Settings** → **Add-ons** → **Blinko**
2. If an update is shown, click **Update**
3. Wait for the update to complete
4. Your data will be preserved
5. Check the **Log** to verify successful update

## Getting Help

If you encounter issues:

1. Check the **DOCS.md** for detailed documentation
2. Review the **Log** tab for error messages
3. Search GitHub Issues for similar problems
4. Create a new issue with:
   - Home Assistant version
   - Add-on version
   - Relevant log excerpts
   - Steps to reproduce the issue

## Next Steps

- Read the **DOCS.md** for usage tips
- Explore Blinko features
- Set up regular backups
- Configure AI integrations (if desired)
- Share notes with others (if needed)

## Uninstalling

If you need to remove Blinko:

1. **Create a backup first** (if you want to keep your data)
2. Stop the add-on
3. Click **Uninstall**
4. Optionally delete data from `/data/blinko/` via SSH/Terminal

---

**Congratulations!** You've successfully installed Blinko on Home Assistant. Enjoy your new AI-powered note-taking system!
