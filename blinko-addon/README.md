# Blinko Home Assistant Add-on (built for use with Ollama LLM)

![Blinko Logo](https://raw.githubusercontent.com/blinkospace/blinko/main/public/logo.png)

A self-hosted note-taking application with AI capabilities, packaged as a Home Assistant add-on. Capture your thoughts instantly, organize them effortlessly, and leverage AI for enhanced search and retrieval.

## About Blinko

Blinko is an open-source note-taking application designed for capturing fleeting thoughts and ideas. It features a streamlined interface optimized for quick note entry, powerful organization tools with tagging support, and optional AI-enhanced search capabilities.

## Features

✨ **Quick Capture** - Jot down thoughts instantly without worrying about formatting  
🏷️ **Smart Organization** - Tag and categorize notes for easy retrieval  
🤖 **AI Integration** - Optional AI-powered search and note retrieval (user-controlled)  
📱 **Mobile Optimized** - Works seamlessly in any mobile browser  
🔒 **Private & Secure** - Your data stays on your Home Assistant instance  
🎨 **Clean Interface** - Distraction-free note-taking experience  
💾 **Automatic Backups** - Built-in database backup capabilities

## Installation

1. **Add the Repository** (if using a custom repository)
   - Navigate to **Supervisor** → **Add-on Store** → **⋮ (Menu)** → **Repositories**
   - Add your repository URL

2. **Install the Add-on**
   - Find "Blinko" in the add-on store
   - Click **Install**
   - Wait for the installation to complete

3. **Configure the Add-on**
   - Go to the **Configuration** tab
   - Set your `nextauth_secret` to a secure random string
   - (Optional) Set `external_url` if accessing via CloudFlare tunnel or reverse proxy
   - Click **Save**

4. **Start the Add-on**
   - Go to the **Info** tab
   - Click **Start**
   - Enable **Start on boot** and **Watchdog** (recommended)

## Configuration

### Required Settings

| Option | Type | Description |
|--------|------|-------------|
| `nextauth_secret` | string | A secure random string for NextAuth encryption. Generate with: `openssl rand -base64 32` |

### Optional Settings

| Option | Type | Description |
|--------|------|-------------|
| `external_url` | string | Full URL when accessing Blinko externally (e.g., `https://blinko.yourdomain.com`). Required if using CloudFlare tunnels or reverse proxies. |

### Example Configuration

```json
{
  "nextauth_secret": "your-secure-random-string-here",
  "external_url": "https://blinko.yourdomain.com"
}
```

## Usage

### Local Access

Access Blinko directly via:
- Direct port: `http://homeassistant.local:1111`
- Your HA IP: `http://192.168.1.x:1111`

### External Access

#### Option 1: CloudFlare Tunnel (Recommended)
1. Set up a CloudFlare tunnel pointing to your Home Assistant instance on port 1111
2. Configure the `external_url` option with your tunnel URL
3. Restart the add-on

#### Option 2: Ingress
> **Note:** Ingress support is currently experimental and may have limitations with authentication callbacks.

Access through Home Assistant:
- Click **Open Web UI** in the add-on interface
- Or navigate via the sidebar if configured

### First-Time Setup

On first launch:
1. Open Blinko in your browser
2. Create your admin account
3. Configure your preferences in Settings
4. Start capturing notes!

## Features & Tips

### Quick Notes (Blinko)
- Perfect for fleeting thoughts and quick captures
- No formatting needed - just write
- Automatically timestamped

### Structured Notes
- Support for markdown formatting
- Tag your notes with `#tags`
- Organize with categories

### AI Features (Optional)
- Enable AI search in settings
- Requires external AI service configuration
- Enhanced semantic search capabilities
- Smart note recommendations

### Mobile Usage
- Add Blinko to your home screen for app-like experience
- Optimized for one-handed note entry
- Works offline (syncs when reconnected)

## Data & Backup

### Data Location
All data is stored in the add-on's persistent data directory:
- Database: `/data/postgres`
- Attachments: `/data/blinko`

### Backup
Your Blinko data is included in Home Assistant backups. To create a backup:
1. Go to **Settings** → **System** → **Backups**
2. Click **Create Backup**
3. Ensure "Blinko" add-on is selected

### Manual Database Backup
Blinko includes built-in database backup features accessible through the web interface settings.

## Troubleshooting

### Add-on Won't Start
- Check the logs for error messages
- Verify your `nextauth_secret` is set correctly
- Ensure port 1111 is not in use by another service

### Images Not Loading After URL Change
If you've changed your access URL (e.g., moved from local IP to CloudFlare tunnel):
1. Update the `external_url` configuration
2. Restart the add-on
3. Note: Existing images may still reference old URLs

### Database Issues
If you encounter database errors:
1. Stop the add-on
2. Check available disk space
3. Review logs for specific errors
4. Restore from a backup if necessary

### Authentication Problems
- Clear browser cache and cookies
- Verify `external_url` matches your actual access URL
- Check that `nextauth_secret` hasn't been changed after initial setup

## Performance

### Resource Usage
- **CPU**: Low (idle), Moderate (during AI operations)
- **RAM**: ~200-500MB typical usage
- **Storage**: Depends on note count and attachments

### Optimization Tips
- Regularly archive old notes
- Limit attachment sizes
- Disable AI features if not needed

## Security

🔒 **Best Practices:**
- Use a strong, unique `nextauth_secret`
- Enable HTTPS when accessing externally
- Keep the add-on updated
- Use CloudFlare tunnel or VPN for remote access
- Regularly backup your data

⚠️ **Important:**
- Never expose port 1111 directly to the internet without HTTPS
- Don't share your `nextauth_secret`
- Consider using Home Assistant's built-in authentication

## Updates

The add-on can be updated through the Home Assistant interface:
1. Go to **Supervisor** → **Dashboard**
2. Find "Blinko" add-on
3. Click **Update** if available

## Support & Links

- 🐛 **Issues**: Report bugs via GitHub issues
- 💬 **Community**: Home Assistant Community Forum
- 📖 **Blinko Docs**: https://blinko.mintlify.app
- 🌟 **Blinko GitHub**: https://github.com/blinkospace/blinko

## Credits

- **Blinko**: Created by the Blinko Space team
- **Add-on**: Community-maintained Home Assistant integration

## License

This add-on packaging is provided as-is. Blinko itself is licensed under its original license terms.

---

**Enjoying Blinko?** Consider starring the [Blinko GitHub repository](https://github.com/blinkospace/blinko) to support the developers! ⭐
