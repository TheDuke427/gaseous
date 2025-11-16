# Blinko Home Assistant Add-on Package

## 🎉 Your Blinko add-on is ready!

This package contains everything you need to create a Home Assistant add-on for Blinko with **full ingress support**.

## 📦 What's Included

### Core Files
- **config.yaml** - Add-on configuration with ingress support
- **Dockerfile** - Container build instructions
- **build.yaml** - Multi-architecture build configuration
- **docker-compose.yml** - Service orchestration (Blinko + PostgreSQL)

### Scripts
- **rootfs/etc/services.d/blinko/run** - Main startup script with ingress detection
- **rootfs/etc/services.d/blinko/finish** - Cleanup script

### Documentation
- **README.md** - Main add-on documentation for users
- **DOCS.md** - Comprehensive usage documentation
- **INSTALLATION.md** - Detailed installation guide
- **CHANGELOG.md** - Version history
- **SETUP_GUIDE.md** - Guide for publishing to GitHub

### Configuration
- **translations/en.json** - English translations for the UI
- **repository.yaml** - Repository metadata

### Missing Items (You Need to Add)
- **icon.png** - 512x512 PNG icon for the add-on
- **logo.png** - 512x512 PNG logo for the store listing

## 🚀 Quick Start

### 1. Create Icons

You need to create two images:

**Option A: Use Material Design Icons**
1. Visit https://materialdesignicons.com/
2. Search for "note-text" or "pencil"
3. Download as PNG at 512x512
4. Save as `icon.png` and `logo.png`

**Option B: Create Custom Icons**
- Use Canva, GIMP, Figma, or Photoshop
- Create 512x512 pixel PNG images
- Use note/pencil/lightbulb imagery

### 2. Set Up GitHub Repository

```bash
# Create a new repository on GitHub named: hassio-addon-blinko

# Clone it locally
git clone https://github.com/YOUR_USERNAME/hassio-addon-blinko.git
cd hassio-addon-blinko

# Copy all files from this package
cp -r /path/to/blinko-addon/* .

# Update repository.yaml with your details
# Update README.md URLs with your repository

# Add icons
cp /path/to/your/icon.png icon.png
cp /path/to/your/logo.png logo.png

# Commit and push
git add .
git commit -m "Initial commit of Blinko add-on"
git push origin main
```

### 3. Install in Home Assistant

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click **⋮** → **Repositories**
4. Add: `https://github.com/YOUR_USERNAME/hassio-addon-blinko`
5. Find and install "Blinko"

### 4. Configure the Add-on

Generate secure secrets:
```bash
openssl rand -base64 32  # For postgres_password
openssl rand -base64 32  # For nextauth_secret
```

Add them to the add-on configuration:
```yaml
postgres_password: "your_generated_password_here"
nextauth_secret: "your_generated_secret_here"
```

### 5. Start and Enjoy!

Start the add-on and access it via the Home Assistant sidebar!

## 🔧 Key Features

### Ingress Support ✅
- Seamless integration with Home Assistant UI
- No need to expose ports
- Automatic SSL through Home Assistant
- Access via sidebar panel

### Database Included ✅
- PostgreSQL 14 automatically configured
- Health checks for reliability
- Automatic data persistence
- Separate volumes for app and database

### Multi-Architecture ✅
- Supports amd64 (Intel/AMD)
- Supports aarch64 (ARM 64-bit, Raspberry Pi 4+)
- Supports armv7 (ARM 32-bit, older Raspberry Pi)
- Supports armhf and i386

### Security ✅
- Configurable passwords
- Secure secrets for authentication
- No default credentials in production
- Isolated network for containers

## 📝 Configuration Options

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `postgres_password` | Yes | "" | PostgreSQL database password |
| `nextauth_secret` | Yes | "" | NextAuth session secret |
| `postgres_db` | No | "blinko" | Database name |
| `postgres_user` | No | "blinkouser" | Database username |
| `nextauth_url` | No | auto | NextAuth URL (auto for ingress) |
| `base_url` | No | auto | Base URL (auto for ingress) |

## 🛠️ How It Works

### Ingress Detection
The add-on automatically detects if it's running with ingress and configures URLs accordingly:

```bash
# With ingress (automatic)
NEXTAUTH_URL: http://homeassistant.local:8123/api/hassio_ingress/...

# Without ingress (fallback)
NEXTAUTH_URL: http://localhost:1111
```

### Container Architecture
```
┌─────────────────────────────────────┐
│   Home Assistant Add-on             │
├─────────────────────────────────────┤
│                                     │
│  ┌───────────────┐  ┌────────────┐ │
│  │  Blinko       │  │ PostgreSQL │ │
│  │  (port 1111)  │◄─┤ (port 5432)│ │
│  └───────────────┘  └────────────┘ │
│         ▲                           │
│         │ Ingress                   │
└─────────┼───────────────────────────┘
          │
    Home Assistant UI
```

## 📚 Files Explanation

### config.yaml
Defines the add-on metadata, configuration schema, and ingress settings. This is the most important file for Home Assistant to recognize and display the add-on.

### rootfs/etc/services.d/blinko/run
The main startup script that:
1. Reads configuration from Home Assistant
2. Detects ingress configuration
3. Generates docker-compose.yml with correct settings
4. Starts Blinko and PostgreSQL containers

### docker-compose.yml (template)
Template for running Blinko services. The startup script replaces placeholders with actual configuration values.

### Dockerfile
Not heavily used in this setup since we're using docker-compose to orchestrate existing images, but required for the add-on structure.

## 🐛 Troubleshooting

### Add-on won't start
- Check logs: Settings → Add-ons → Blinko → Log
- Verify configuration is set correctly
- Ensure secrets are not empty

### Can't access via ingress
- Verify add-on is running
- Refresh browser (hard refresh)
- Check Home Assistant logs

### Database errors
- Stop and restart add-on
- Check PostgreSQL health in logs
- Verify data directory permissions

## 🎯 Next Steps

1. ✅ Create icon.png and logo.png
2. ✅ Set up GitHub repository
3. ✅ Update repository.yaml with your info
4. ✅ Update README.md with your URLs
5. ✅ Push to GitHub
6. ✅ Test installation in Home Assistant
7. ✅ Share with the community!

## 📞 Support

For issues with the add-on structure or setup:
- Review SETUP_GUIDE.md
- Check Home Assistant add-on development docs
- Visit Home Assistant Community Forum

For issues with Blinko itself:
- Visit https://github.com/blinkospace/blinko

## 📄 License

This add-on packaging is provided as-is. Blinko itself is licensed under its own terms at the Blinko repository.

---

**Happy note-taking with Blinko on Home Assistant! 📝✨**
