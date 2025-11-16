# Add-on Structure Explanation

This document explains the structure and purpose of each file in the Blinko Home Assistant add-on.

## Directory Structure

```
blinko-addon/
├── config.yaml                    # Main add-on configuration
├── build.yaml                     # Multi-architecture build config
├── Dockerfile                     # Container build instructions
├── docker-compose.yml             # Service orchestration template
├── repository.yaml                # Repository metadata
│
├── README.md                      # Main user documentation
├── DOCS.md                        # Detailed usage documentation
├── INSTALLATION.md                # Installation guide
├── CHANGELOG.md                   # Version history
├── SETUP_GUIDE.md                 # Publishing guide
├── SETUP_CHECKLIST.md             # Setup checklist
├── QUICK_START.md                 # Quick start guide
├── PACKAGE_README.md              # Package overview
├── STRUCTURE.md                   # This file
│
├── icon.png.txt                   # Placeholder - CREATE REAL icon.png!
├── logo.png.txt                   # Placeholder - CREATE REAL logo.png!
│
├── rootfs/                        # Root filesystem overlay
│   └── etc/
│       └── services.d/
│           └── blinko/
│               ├── run            # Main startup script
│               └── finish         # Cleanup script
│
└── translations/
    └── en.json                    # English UI translations
```

## Core Configuration Files

### config.yaml
**Purpose:** Primary add-on configuration file
**Key features:**
- Defines add-on metadata (name, version, description)
- Specifies supported architectures
- Configures ingress settings
- Defines configuration schema
- Maps ports

**Important sections:**
```yaml
ingress: true              # Enables ingress
ingress_port: 1111         # Port for ingress
panel_icon: mdi:note-text  # Sidebar icon
options:                   # Default configuration
  postgres_password: ""
  nextauth_secret: ""
schema:                    # Configuration validation
  postgres_password: password
  nextauth_secret: password
```

### build.yaml
**Purpose:** Specifies base images for different architectures
**Content:**
```json
{
  "build_from": {
    "aarch64": "ghcr.io/hassio-addons/base-aarch64:16.3.2",
    "amd64": "ghcr.io/hassio-addons/base-amd64:16.3.2",
    "armv7": "ghcr.io/hassio-addons/base-armv7:16.3.2",
    ...
  }
}
```

### Dockerfile
**Purpose:** Defines how to build the add-on container
**Key steps:**
1. Uses base image from build.yaml
2. Installs docker and docker-compose
3. Copies startup scripts
4. Sets executable permissions

### docker-compose.yml
**Purpose:** Template for orchestrating Blinko and PostgreSQL
**Services:**
- `blinko-website`: Main Blinko application
- `postgres`: PostgreSQL database

**Note:** This is a template. The actual file is generated at runtime with configuration values.

## Runtime Scripts

### rootfs/etc/services.d/blinko/run
**Purpose:** Main startup script
**Responsibilities:**
1. Read configuration from Home Assistant
2. Validate required fields
3. Detect ingress configuration
4. Generate docker-compose.yml with correct values
5. Create data directories
6. Start docker-compose

**Key features:**
- Automatic ingress URL detection
- Environment variable substitution
- Health check validation
- Fallback to non-ingress mode

**Ingress detection logic:**
```bash
if bashio::var.has_value "$(bashio::addon.ingress_entry)"; then
    # Use ingress URLs
    ingress_entry=$(bashio::addon.ingress_entry)
    nextauth_url="http://${ingress_interface}:${ingress_port}"
else
    # Fallback to direct access
    nextauth_url="http://localhost:1111"
fi
```

### rootfs/etc/services.d/blinko/finish
**Purpose:** Cleanup script when service stops
**Action:** Stops docker-compose services gracefully

## Documentation Files

### README.md
**Audience:** End users installing the add-on
**Content:**
- Installation instructions
- Configuration guide
- Usage examples
- Troubleshooting tips

### DOCS.md
**Audience:** End users needing detailed help
**Content:**
- Comprehensive feature documentation
- Advanced configuration
- Backup and restore procedures
- FAQ

### INSTALLATION.md
**Audience:** Users installing for the first time
**Content:**
- Step-by-step installation walkthrough
- Configuration examples
- Verification steps
- Troubleshooting installation issues

### SETUP_GUIDE.md
**Audience:** Developers publishing the add-on
**Content:**
- GitHub repository setup
- Icon creation guidance
- Publishing steps
- Maintenance tips

### SETUP_CHECKLIST.md
**Audience:** Developers during setup
**Content:**
- Checkbox list of all setup steps
- Quick reference for completion status

### QUICK_START.md
**Audience:** Anyone wanting a fast overview
**Content:**
- Condensed setup steps
- Time estimates
- Common issues
- Quick reference

## Required Images

### icon.png
**Purpose:** Icon displayed in the add-on store
**Specifications:**
- Format: PNG
- Size: 512x512 pixels
- Content: Blinko logo or note-related icon

**Note:** The included icon.png.txt is a placeholder. You MUST create an actual PNG file.

### logo.png
**Purpose:** Larger logo for add-on listing
**Specifications:**
- Format: PNG
- Size: 512x512 pixels (minimum)
- Content: Same as icon or more detailed

**Note:** The included logo.png.txt is a placeholder. You MUST create an actual PNG file.

## Translation Files

### translations/en.json
**Purpose:** English language strings for the UI
**Content:**
- Configuration field labels
- Descriptions
- Network port descriptions

**Example:**
```json
{
  "configuration": {
    "postgres_password": {
      "name": "PostgreSQL Password",
      "description": "Password for the database..."
    }
  }
}
```

## Repository Configuration

### repository.yaml
**Purpose:** Metadata for the add-on repository
**Content:**
- Repository name
- URL
- Maintainer information

**Must update:**
- `url`: Your GitHub repository URL
- `maintainer`: Your name and email

## Data Storage

### Runtime Data Locations

When the add-on runs, data is stored in:

```
/addon_config/
├── blinko-data/           # Blinko application data
│   └── (notes, attachments, etc.)
└── postgres-data/         # PostgreSQL database
    └── (database files)
```

These directories are:
- Automatically created by the startup script
- Persisted across add-on restarts
- Included in Home Assistant backups
- Mounted as volumes in docker-compose

## Service Architecture

```
┌───────────────────────────────────────────────┐
│         Home Assistant Add-on                 │
│                                               │
│  ┌──────────────────────────────────────┐   │
│  │  rootfs/etc/services.d/blinko/run    │   │
│  │  (Startup Script)                    │   │
│  └──────────────┬───────────────────────┘   │
│                 │                             │
│                 ▼                             │
│  ┌──────────────────────────────────────┐   │
│  │     Generated docker-compose.yml     │   │
│  └──────────────┬───────────────────────┘   │
│                 │                             │
│                 ├─────────┐                   │
│                 ▼         ▼                   │
│  ┌──────────────────┐  ┌──────────────────┐ │
│  │  Blinko          │  │  PostgreSQL 14   │ │
│  │  (port 1111)     │◄─┤  (internal)      │ │
│  │  blinkospace/    │  │  postgres:14     │ │
│  │  blinko:latest   │  │                  │ │
│  └──────────────────┘  └──────────────────┘ │
│         ▲                                     │
│         │ Ingress                             │
└─────────┼─────────────────────────────────────┘
          │
          ▼
   Home Assistant UI
     (Sidebar Panel)
```

## Configuration Flow

1. **User configures add-on** in Home Assistant UI
2. **Config values saved** to Home Assistant
3. **Startup script runs** (`rootfs/etc/services.d/blinko/run`)
4. **Script reads config** using `bashio::config`
5. **Ingress detection** checks for ingress entry
6. **docker-compose.yml generated** with actual values
7. **Services started** via docker-compose
8. **Health checks monitor** service status
9. **Ingress proxies** requests to Blinko

## Key Technologies

- **S6 Overlay:** Service supervision
- **Bashio:** Home Assistant helper functions
- **Docker Compose:** Service orchestration
- **Next.js:** Blinko application framework
- **PostgreSQL:** Database backend
- **Home Assistant Ingress:** Secure proxy

## Security Considerations

### Secrets Management
- Passwords never hardcoded
- Configuration values encrypted by Home Assistant
- Secrets passed via environment variables

### Network Isolation
- Containers on isolated bridge network
- PostgreSQL not exposed externally
- Ingress provides secure proxy

### Data Protection
- Data stored in protected add-on directory
- Included in Home Assistant backups
- User controls database access

## Customization Points

### Easy to Customize
- Configuration defaults (config.yaml)
- UI translations (translations/en.json)
- Documentation (all .md files)
- Startup behavior (run script)

### Advanced Customization
- Add environment variables
- Modify docker-compose template
- Add additional services
- Custom health checks

## Maintenance

### Version Updates
1. Update `version` in config.yaml
2. Add entry to CHANGELOG.md
3. Test thoroughly
4. Commit and tag release
5. Users update via HA UI

### Blinko Updates
When Blinko releases new versions:
1. Test new version locally
2. Update references if needed
3. Update documentation
4. Release new add-on version

## Troubleshooting Reference

### Check These First
1. Add-on logs: Settings → Add-ons → Blinko → Log
2. Home Assistant logs: Settings → System → Logs
3. Container status: `docker ps` (via SSH)
4. Configuration: Settings → Add-ons → Blinko → Configuration

### Common Issues
- **Won't start:** Check required secrets are set
- **No ingress:** Verify config.yaml has ingress: true
- **Database errors:** Check PostgreSQL health in logs
- **Icon missing:** Create actual PNG files

## Additional Resources

- **Home Assistant Add-on Docs:** https://developers.home-assistant.io/docs/add-ons
- **Bashio Documentation:** https://github.com/hassio-addons/bashio
- **Docker Compose Docs:** https://docs.docker.com/compose/
- **Blinko Repository:** https://github.com/blinkospace/blinko

---

This structure provides a complete, production-ready Home Assistant add-on with ingress support for Blinko!
