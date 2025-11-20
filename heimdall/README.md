# 🏛️ Heimdall Dashboard for Home Assistant

[![Home Assistant Add-on](https://img.shields.io/badge/Home%20Assistant-Add--on-blue.svg)](https://www.home-assistant.io/addons/)
[![Version](https://img.shields.io/badge/version-2.6.2-green.svg)](https://github.com/linuxserver/Heimdall)
[![Maintenance](https://img.shields.io/badge/maintained-yes-brightgreen.svg)](https://github.com/yourusername/heimdall-addon)

Transform your Home Assistant into the ultimate application hub with Heimdall - the elegant, Norse-mythology-inspired dashboard that sees all and organizes everything! 

## ✨ What is Heimdall?

Heimdall Application Dashboard is your one-stop solution for organizing all your web applications, self-hosted services, and favorite websites. Think of it as your digital command center - beautiful, functional, and always ready.

### 🎯 Perfect For:
- 🏠 **Home Lab Enthusiasts** - Organize all your self-hosted services
- 🚀 **Power Users** - Quick access to all your tools and apps
- 🎨 **Minimalists** - Clean, elegant interface without the clutter
- 🔧 **Tinkerers** - Fully customizable to match your style

## 🌟 Features

- **📱 Responsive Design** - Looks amazing on everything from phones to 4K displays
- **🎨 Customizable** - Upload your own backgrounds, choose your color schemes
- **🔍 Built-in Search** - Integrated Google, Bing, or DuckDuckGo search
- **📊 Enhanced Apps** - Live stats for supported applications (Plex, Sonarr, etc.)
- **🏷️ Smart Organization** - Tag and categorize your applications
- **🌐 No Database Required** - Simple SQLite backend
- **🔒 Optional Authentication** - Protect with HTTP basic auth if needed
- **☁️ Cloudflare Tunnel Ready** - Perfect for secure remote access

## 🚀 Installation

### Prerequisites
- Home Assistant OS or Supervised installation
- Port 7990 available (or configure your preferred port)

### Quick Install

1. **Add the Repository**
   - Navigate to **Supervisor** → **Add-on Store**
   - Click the three dots menu → **Repositories**
   - Add this repository URL (or use local add-ons)

2. **Install Heimdall**
   - Find "Heimdall" in the add-on list
   - Click **Install**
   - Wait for the build to complete (first install takes ~2-3 minutes)

3. **Configure** (optional)
```yaml
   timezone: America/New_York
   allow_internal_requests: true  # Enable to access local network services
   ssl: false  # Enable if you have SSL certificates
```

4. **Start the Add-on**
   - Click **Start**
   - Check the logs for "Heimdall is running!"

## 🎮 Usage

### Accessing Heimdall
Open your browser and navigate to:
```
http://[YOUR-HOME-ASSISTANT-IP]:7990
```

### First Steps

1. **Add Your First App**
   - Click "Add an application here"
   - Enter the app name (e.g., "Home Assistant")
   - Add the URL
   - Choose an icon (500+ built-in icons!)
   - Pick a color or let it auto-match

2. **Customize Your Background**
   - Click the settings gear (bottom right)
   - Upload your favorite wallpaper
   - Or use the built-in Trianglify generator for geometric patterns

3. **Organize with Tags**
   - Create tags like "Media", "Automation", "Monitoring"
   - Pin your most-used apps for quick access

### 🌐 Cloudflare Tunnel Setup

Perfect for secure remote access:

1. Point your tunnel to: `http://[HA-IP]:7990`
2. No ingress needed - direct connection!
3. Optional: Enable SSL in the add-on config if using CF certificates

## ⚙️ Configuration Options

| Option | Default | Description |
|--------|---------|-------------|
| `timezone` | `America/New_York` | Your local timezone for accurate timestamps |
| `allow_internal_requests` | `true` | Allow Heimdall to access local network IPs |
| `ssl` | `false` | Enable HTTPS support |
| `certfile` | `fullchain.pem` | SSL certificate filename |
| `keyfile` | `privkey.pem` | SSL private key filename |

## 💾 Data Persistence

All your settings, icons, and configurations are stored in:
```
/config/heimdall/
```

This means:
- ✅ Survives add-on updates
- ✅ Survives Home Assistant restarts  
- ✅ Easy to backup
- ✅ Easy to migrate

## 🎨 Enhanced Applications

Heimdall supports live stats for many popular applications:

**Media Servers**: Plex, Emby, Jellyfin  
**Download Clients**: SABnzbd, NZBGet, qBittorrent, Transmission  
**PVRs**: Sonarr, Radarr, Lidarr, Readarr  
**Home Automation**: Home Assistant, openHAB  
**Monitoring**: Tautulli, Grafana, Netdata  
**And many more!**

## 🐛 Troubleshooting

### Add-on won't start?
- Check logs for errors
- First start takes 1-2 minutes (setting permissions)
- Ensure port 7990 is not in use

### Can't access local services?
- Ensure `allow_internal_requests: true` in config
- Check your network allows communication between containers

### Background image won't save?
- Max file size: 30MB
- Supported formats: JPG, PNG, GIF
- Check `/config/heimdall/backgrounds/` permissions

### API Access Errors in Logs?
- These are harmless - the add-on uses default values
- Your configured settings are still applied

## 🤝 Contributing

Found a bug? Have a feature request? Contributions are welcome!

### Built With
- [Laravel](https://laravel.com/) - PHP Framework
- [Alpine Linux](https://alpinelinux.org/) - Base OS
- [Nginx](https://nginx.org/) - Web Server
- [PHP-FPM](https://www.php.net/) - PHP FastCGI Process Manager

### Credits
- Original Heimdall by [LinuxServer.io](https://github.com/linuxserver/Heimdall)
- Home Assistant Add-on by the Community
- Icons by [FontAwesome](https://fontawesome.com/)

## 📝 License

This add-on is provided as-is under the MIT License.

## 🙏 Support

Love Heimdall? Here's how you can help:

- ⭐ Star this repository
- 🐛 Report bugs and request features
- 💬 Help others in the discussions
- ☕ Support the original developers at [LinuxServer.io](https://www.linuxserver.io/donate)

---

<div align="center">
  
**[Documentation](https://heimdall.site)** • **[Discord](https://discord.gg/CCjHKn4)** • **[Forum](https://discourse.heimdall.site)**

*May your dashboard be forever organized! 🛡️*

</div>
