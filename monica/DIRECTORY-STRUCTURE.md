# Monica Add-on Directory Structure

```
monica/
│
├── 00-START-HERE.md              # 👈 Start with this file!
├── README.md                      # Main user documentation
├── QUICKSTART.md                  # Quick setup guide
├── INSTALL.md                     # Repository installation guide
├── DOCS.md                        # Developer documentation
├── SUMMARY.md                     # Complete feature overview
├── CHANGELOG.md                   # Version history and changes
│
├── config.yaml                    # Add-on configuration schema ⚙️
├── build.yaml                     # Build configuration for architectures
├── Dockerfile                     # Container image definition 🐳
│
├── icon.json                      # Add-on icon metadata
├── logo.svg                       # Add-on logo graphic
├── repository.json                # Repository metadata (for root)
├── .gitignore                     # Git ignore rules
│
└── rootfs/                        # Root filesystem overlay
    └── etc/
        ├── cont-init.d/           # Initialization scripts (run once at startup)
        │   └── 10-monica.sh       # ⭐ Main setup script
        │
        ├── services.d/            # Service definitions (run continuously)
        │   ├── nginx/
        │   │   └── run            # Nginx web server runner
        │   └── php-fpm/
        │       └── run            # PHP-FPM processor runner
        │
        └── nginx/
            ├── nginx.conf         # Main nginx configuration
            └── templates/
                └── monica.conf.template  # Site configuration (with ingress)
```

## File Purposes

### Documentation Files

| File | Purpose | For |
|------|---------|-----|
| `00-START-HERE.md` | Quick overview and setup | You (maintainer) |
| `README.md` | Complete user guide | End users |
| `QUICKSTART.md` | Step-by-step setup | New users |
| `INSTALL.md` | Repo setup and GitHub Actions | You (maintainer) |
| `DOCS.md` | Technical architecture details | Developers |
| `SUMMARY.md` | Feature list and capabilities | Everyone |
| `CHANGELOG.md` | Version history | Everyone |

### Configuration Files

| File | Purpose |
|------|---------|
| `config.yaml` | Defines add-on settings, options, and schema |
| `build.yaml` | Specifies base images for different architectures |
| `Dockerfile` | Builds the container image with all dependencies |

### Runtime Files (rootfs/)

| File | Purpose | When Runs |
|------|---------|-----------|
| `10-monica.sh` | Setup and configuration | Once at startup |
| `nginx/run` | Starts web server | Continuously |
| `php-fpm/run` | Starts PHP processor | Continuously |
| `nginx.conf` | Main web server config | At nginx start |
| `monica.conf.template` | Site-specific config | Processed at startup |

## How It Works

### Startup Sequence

```
1. Container starts
   ↓
2. S6 overlay initializes
   ↓
3. cont-init.d scripts run
   └─ 10-monica.sh:
      ├─ Read configuration
      ├─ Wait for MariaDB
      ├─ Generate APP_KEY
      ├─ Create .env file
      ├─ Run database migrations
      └─ Set permissions
   ↓
4. services.d processes start
   ├─ nginx/run → Web server
   └─ php-fpm/run → PHP processor
   ↓
5. Add-on ready! 🎉
```

### Request Flow

```
User clicks in sidebar
   ↓
Home Assistant Ingress
(HTTPS, Authentication)
   ↓
Nginx (port 80)
   ↓
PHP-FPM (Monica Laravel)
   ↓
MariaDB (data storage)
```

## Key Scripts Explained

### 10-monica.sh (Init Script)
- **Runs:** Once at container startup
- **Does:**
  - Reads add-on configuration via bashio
  - Waits for MariaDB to be available
  - Generates or loads APP_KEY
  - Creates .env file with database credentials
  - Runs database migrations if needed
  - Sets up ingress configuration
  - Fixes file permissions

### nginx/run (Service)
- **Runs:** Continuously, monitored by S6
- **Does:**
  - Starts nginx web server
  - Serves static files
  - Proxies PHP requests to FPM
  - Handles ingress paths

### php-fpm/run (Service)
- **Runs:** Continuously, monitored by S6
- **Does:**
  - Starts PHP FastCGI Process Manager
  - Executes Monica PHP code
  - Handles database queries
  - Processes user requests

## Data Persistence

| What | Where | Persists? |
|------|-------|-----------|
| Database | MariaDB add-on | ✅ Yes |
| APP_KEY | `/data/.app_key` | ✅ Yes |
| Uploads | Database (BLOB) | ✅ Yes |
| Configuration | HA add-on config | ✅ Yes |
| Logs | Container stdout/stderr | ❌ No |
| Cache | `/var/www/monica/storage` | ❌ No |

## Architecture Support

The add-on builds for all these platforms:

- ✅ **amd64** - Standard PCs, servers
- ✅ **aarch64** - Raspberry Pi 4, ARM servers
- ✅ **armhf** - Older Raspberry Pi models
- ✅ **armv7** - ARM v7 devices
- ✅ **i386** - 32-bit x86 (legacy)

## File Sizes (Approximate)

- `Dockerfile`: ~3.5 KB
- `config.yaml`: ~1.3 KB
- `10-monica.sh`: ~6.9 KB
- `nginx.conf`: ~0.9 KB
- `monica.conf.template`: ~2.2 KB
- `README.md`: ~8.6 KB

**Total repository size:** ~50 KB (excluding built images)
**Built image size:** ~500-800 MB (varies by architecture)

## Quick Reference

### To modify database settings:
→ Edit `config.yaml` schema
→ Update `10-monica.sh` to read new settings

### To change web server config:
→ Edit `nginx.conf` or `monica.conf.template`
→ Rebuild container

### To update Monica version:
→ Edit `Dockerfile` git clone line
→ Update version in `config.yaml`

### To add new features:
→ Update `config.yaml` schema
→ Modify `10-monica.sh` to handle new options
→ Update documentation

## Common Paths

Inside the container:

| Path | Contains |
|------|----------|
| `/var/www/monica/` | Monica application files |
| `/var/www/monica/.env` | Laravel environment config |
| `/var/www/monica/storage/` | Cache, logs, sessions |
| `/data/.app_key` | Persistent encryption key |
| `/etc/nginx/` | Web server configuration |
| `/var/run/php-fpm.sock` | PHP-FPM socket |

## Testing Checklist

Before publishing:

- [ ] Database connection works
- [ ] Migrations run successfully  
- [ ] Web interface loads
- [ ] User registration works
- [ ] Ingress path works
- [ ] Direct port access works
- [ ] SMTP settings work (optional)
- [ ] Logs are readable
- [ ] Restarts work correctly
- [ ] Updates preserve data

## Support Files

All documentation is self-contained:

- **User problems?** → `README.md`, `QUICKSTART.md`
- **Setup issues?** → `INSTALL.md`
- **Development?** → `DOCS.md`
- **Features?** → `SUMMARY.md`
- **Updates?** → `CHANGELOG.md`
- **Quick start?** → `00-START-HERE.md`

---

**Remember:** The `monica/` folder is self-contained and ready to add to your repository!
