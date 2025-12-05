# 🏠 Home Assistant Add-ons Collection

A curated collection of Home Assistant add-ons featuring both optimized versions of popular open-source applications and custom-built solutions for specialized needs.

## 📦 Available Add-ons

### Productivity & Organization
- **[Monica](./monica)** - Personal CRM with MariaDB integration for managing relationships and contacts
- **[Blinko](./blinko-addon)** - AI-enhanced note-taking application with Ollama integration
- **[Dashy](./dashy)** - Highly customizable dashboard with dynamic section behavior

### Media & Entertainment
- **[Audiobookshelf](./audiobookshelf)** - Self-hosted audiobook and podcast server with persistent data storage
- **[Heimdall](./heimdall)** - Application dashboard and launcher for all your web applications

### Utilities
- **[Unrar Tool](./unrar_tool)** - Custom-built automated RAR file extraction utility
- **[XDCC Downloader](./xdcc-downloader)** - Custom IRC client with DCC file transfer capabilities
- **[Gaseous Server](./gaseous_server)** - ROM management and gaming server

## 🚀 Features

- **Production-Ready**: Each add-on is thoroughly tested for stability and performance
- **Data Persistence**: Proper volume mapping ensures your data survives updates
- **Easy Installation**: One-click installation through the Home Assistant Add-on Store
- **Documentation**: Comprehensive setup guides and troubleshooting tips for each add-on

## 📋 Installation

1. Navigate to your Home Assistant instance
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the three dots menu → **Repositories**
4. Add this repository URL: `https://github.com/TheDuke427/gaseous`
5. Find the desired add-on in the store and click "Install"

## 📝 Repository Structure

Each add-on follows the standard Home Assistant add-on structure:
- `config.json` - Add-on configuration and metadata
- `Dockerfile` - Container build instructions
- `run.sh` - Startup script
- `README.md` - Add-on specific documentation

## 📄 License

This repository contains both original work and modifications of open-source projects. Please refer to individual add-on directories for specific licensing information.

---

*Building robust, self-hosted solutions for Home Assistant - one add-on at a time.*
