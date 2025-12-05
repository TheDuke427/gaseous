## 🚀 Jump - Home Assistant Add-on

**A beautifully crafted, lightning-fast startpage for your self-hosted empire.**

Transform your browser's new tab into a sleek command center. Jump gives you instant access to all your services with real-time status monitoring, gorgeous backgrounds, and a design that actually sparks joy.

---

## ✨ Features

- 🎨 **Stunning UI** - Clean, modern interface that looks professional out of the box
- ⚡ **Real-time Monitoring** - Know instantly if your services are up or down
- 🏷️ **Smart Organization** - Tag and categorize your services however you want
- 🔍 **Quick Search** - Find anything with keyboard shortcuts (`ctrl+shift+/`)
- 🌄 **Custom Backgrounds** - Drop in your own images or pull from Unsplash
- 🌤️ **Weather Integration** - OpenWeatherMap support for local conditions
- 📱 **Mobile Responsive** - Looks great on any device
- 🎯 **Dashboard Icons** - 2000+ pre-made icons at your fingertips
- 🚫 **Zero Tracking** - Your data stays yours. Period.

---

## 🎬 Quick Start

### Installation

1. Copy this add-on folder to `/addons/jump/`
2. **Settings** → **Add-ons** → **⋮** (menu) → **Check for updates**
3. Install **Jump** from your local add-ons
4. Hit **Start**
5. Navigate to `http://homeassistant.local:4500`

**That's it.** You're ready to jump.

---

## ⚙️ Configuration

Customize Jump through the add-on configuration panel or edit the YAML directly:

```yaml
sitename: "Mission Control"
showclock: true
showsearch: true
checkstatus: true
bgblur: 40
bgbright: 85
owmapikey: "your-api-key"
latlong: "37.7749,-122.4194"
```

### 🎛️ All Configuration Options

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `sitename` | string | "Jump" | Your personal touch at the top |
| `showclock` | bool | true | Display the clock |
| `ampmclock` | bool | false | 12-hour format instead of 24 |
| `showgreeting` | bool | true | "Good morning" vibes |
| `customgreeting` | string | - | Override with your own greeting |
| `showsearch` | bool | true | Enable the search bar |
| `altlayout` | bool | false | Try the alternative site layout |
| `customwidth` | int | - | Max page width in pixels |
| `bgblur` | int | - | Background blur (0-100) |
| `bgbright` | int | - | Background brightness (0-100) |
| `unsplashapikey` | string | - | Unsplash API for random backgrounds |
| `unsplashcollections` | string | - | Specific Unsplash collections (comma-separated) |
| `owmapikey` | string | - | OpenWeatherMap API key |
| `latlong` | string | - | Your coordinates: "lat,long" |
| `metrictemp` | bool | true | Celsius > Fahrenheit |
| `checkstatus` | bool | true | Monitor site availability |
| `statuscache` | int | 5 | Cache status checks (minutes) |
| `language` | string | "en-gb" | Language code |
| `debug` | bool | false | Show detailed errors |

---

## 🎨 Customization

All your configuration lives in `/config/jump/`. Edit with File Editor, SSH, or Samba - whatever floats your boat.

### 📍 Adding Sites

Edit `/config/jump/sites/sites.json`:

```json
{
    "default": {
        "newtab": true,
        "nofollow": true
    },
    "sites": [
        {
            "name": "Jellyfin",
            "url": "https://media.mydomain.com",
            "description": "Movie night headquarters",
            "icon": "jellyfin",
            "tags": ["home", "media"]
        },
        {
            "name": "Nextcloud",
            "url": "https://cloud.mydomain.com",
            "icon": "nextcloud",
            "tags": ["home", "productivity"]
        },
        {
            "name": "Portainer",
            "url": "http://192.168.1.100:9000",
            "icon": "portainer",
            "tags": ["admin", "docker"]
        }
    ]
}
```

**Pro Tips:**
- 🏠 Add `"home"` tag to show sites on your main screen
- 🎯 Use multiple tags: `["home", "media", "external"]`
- 🖼️ Use [Dashboard Icons](https://github.com/walkxcode/dashboard-icons) by name (no extension needed)
- 🎨 Or drop custom PNGs in `/config/jump/sites/icons/`

### 🔍 Search Engines

Edit `/config/jump/search/searchengines.json`:

```json
[
    {
        "name": "Google",
        "url": "https://www.google.com/search?q="
    },
    {
        "name": "DuckDuckGo",
        "url": "https://duckduckgo.com/?q="
    },
    {
        "name": "GitHub",
        "url": "https://github.com/search?q="
    }
]
```

The first one is your default. Hit `ctrl+shift+/` to search instantly.

### 🌄 Backgrounds

Drop any images into `/config/jump/backgrounds/` and Jump will rotate through them randomly.

**Or get fancy with Unsplash:**
1. Get an API key from [Unsplash Developers](https://unsplash.com/developers)
2. Add to config: `unsplashapikey: "your-key"`
3. Optional: Pick collections with `unsplashcollections: "123456,789012"`

### 🎨 Custom Favicon

Replace `/config/jump/favicon/icon.png` with your own branding.

---

## 📝 Editing Files

Choose your weapon:

### Option 1: File Editor Add-on ⭐ *Recommended*
1. Install **File Editor** from Add-on Store
2. Navigate to `jump` folder  
3. Edit, save, restart Jump add-on

### Option 2: SSH Ninja Mode
```bash
cd /config/jump/sites/
nano sites.json
```

### Option 3: Samba Share
Map `\\homeassistant\config\jump\` and edit with your favorite editor.

**Remember:** Restart the Jump add-on after changes!

---

## 🏷️ Tagging Strategy

Tags are powerful. Use them wisely:

```json
{
    "name": "Plex",
    "tags": ["home"]           // Shows on home screen
}

{
    "name": "Overseerr", 
    "tags": ["home", "media"]  // Home screen + media filter
}

{
    "name": "Monitoring Stack",
    "tags": ["admin"]          // Only shows when filtering by "admin"
}

{
    "name": "Internal Proxmox",
    "tags": ["admin", "internal"]  // Multiple filters
}
```

Sites with **no tags** or the `"home"` tag appear by default. Everything else requires filtering.

---

## 🎯 Keyboard Shortcuts

- `ctrl+shift+/` - Open search bar
- Start typing immediately to search

---

## 🌐 Port

Jump lives on **port 4500**.

Access at: `http://homeassistant.local:4500`

---

## 🛠️ Troubleshooting

**500 Error?**
- Check your JSON syntax at [jsonlint.com](https://jsonlint.com)
- Make sure at least one site has the `"home"` tag
- Enable `debug: true` in add-on config

**Sites not showing?**
- Verify JSON is valid
- Check that sites have `"home"` tag or no tags at all
- Restart the add-on

**Icons missing?**
- Custom icons go in `/config/jump/sites/icons/`
- Dashboard Icons work by name alone: `"icon": "portainer"`
- Check filename spelling

---

## 💝 Credits

Built on the excellent [Jump](https://github.com/daledavies/jump) by Dale Davies.

Adapted for Home Assistant with love ❤️

---

## 📦 Version

**1.0.0** - Initial release

---

**Now go make your startpage legendary.** 🚀