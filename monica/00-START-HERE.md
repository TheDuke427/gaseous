# 🎉 Monica Home Assistant Add-on - Complete Package

## What You Have

A **complete, production-ready Home Assistant add-on** for Monica Personal CRM with:

✅ Full ingress support (sidebar access)
✅ MariaDB integration 
✅ Automatic setup and configuration
✅ Multi-architecture support
✅ Comprehensive documentation
✅ Security best practices
✅ SMTP email support

## Quick Setup (3 Steps)

### 1. Add to Your Repository

Copy the entire `monica` folder to your GitHub repository:

```
https://github.com/TheDuke427/gaseous/
```

Place it at the root level:
```
gaseous/
├── monica/          ← Add this folder
│   ├── config.yaml
│   ├── Dockerfile
│   ├── rootfs/
│   └── ...
└── repository.json  ← Also add this if it doesn't exist
```

### 2. Commit and Push

```bash
cd gaseous
git add monica/
git add repository.json  # if new
git commit -m "Add Monica Personal CRM add-on"
git push origin main
```

### 3. You're Done!

Users can now add your repository to Home Assistant and install Monica!

---

## Files Included

### 📋 Core Add-on Files
- **config.yaml** - Add-on configuration and schema
- **build.yaml** - Multi-architecture build config  
- **Dockerfile** - Container image definition
- **rootfs/** - Runtime files (scripts, configs)

### 📚 Documentation
- **README.md** - Main user documentation
- **QUICKSTART.md** - Step-by-step setup guide
- **DOCS.md** - Developer documentation
- **INSTALL.md** - Repository setup instructions
- **SUMMARY.md** - Complete feature overview
- **CHANGELOG.md** - Version history

### 🎨 Assets
- **logo.svg** - Add-on logo
- **icon.json** - Icon configuration
- **.gitignore** - Git ignore rules

### 🔧 Utilities
- **repository.json** - Repository metadata (for root)

---

## User Installation

Once in your repository, users install it like this:

1. **Add Repository:**
   - Settings → Add-ons → Add-on Store
   - Menu (⋮) → Repositories
   - Add: `https://github.com/TheDuke427/gaseous`

2. **Install Monica:**
   - Find "Monica Personal CRM" in store
   - Click Install
   - Configure database settings
   - Start the add-on
   - Access from sidebar!

See **QUICKSTART.md** for complete user instructions.

---

## Configuration Example

Users will configure it like this:

```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "secure_password"
app_env: production
app_disable_signup: true
```

---

## Key Features

### 🏠 Home Assistant Integration
- Sidebar access via ingress
- Works with MariaDB add-on
- Automatic SSL and authentication
- Supports all architectures

### 🔒 Security
- Auto-generated encryption keys
- Secure password hashing
- XSS/CSRF protection
- Configurable signup controls

### 📧 Email Support
- SMTP configuration for reminders
- Multiple provider support (Gmail, SendGrid, etc.)
- Test mode for debugging

### 🚀 Monica CRM Features
- Contact management
- Relationship tracking
- Birthday reminders
- Activity logging
- Personal journal
- Document storage
- Task management
- CardDAV sync

---

## Testing Locally

Before publishing, test locally:

```bash
# Build the image
docker build -t monica-test ./monica/

# Or build for specific architecture
docker buildx build --platform linux/amd64 -t monica-amd64 ./monica/
```

---

## GitHub Actions (Optional)

For automatic builds, add `.github/workflows/builder.yml` to your repo.

Example provided in **INSTALL.md**.

---

## File Structure

```
monica/
├── config.yaml                          # Add-on configuration
├── build.yaml                           # Build settings
├── Dockerfile                           # Container definition
├── README.md                            # User docs
├── QUICKSTART.md                        # Quick start guide
├── DOCS.md                              # Developer docs
├── INSTALL.md                           # Repo setup guide
├── SUMMARY.md                           # Feature summary
├── CHANGELOG.md                         # Version history
├── icon.json                            # Icon config
├── logo.svg                             # Logo graphic
├── .gitignore                           # Git ignore
├── repository.json                      # Repo metadata
└── rootfs/                              # Runtime filesystem
    └── etc/
        ├── cont-init.d/
        │   └── 10-monica.sh            # Setup script
        ├── services.d/
        │   ├── nginx/run               # Web server
        │   └── php-fpm/run             # PHP processor
        └── nginx/
            ├── nginx.conf               # Main config
            └── templates/
                └── monica.conf.template # Site config
```

---

## Architecture

```
Home Assistant
    ↓ (ingress)
Nginx (port 80)
    ↓ (fastcgi)
PHP-FPM (Monica)
    ↓ (mysql)
MariaDB (existing add-on)
```

---

## Database Setup

Users need to create a database first:

```sql
CREATE DATABASE monica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'monica'@'%' IDENTIFIED BY 'password';
GRANT ALL PRIVILEGES ON monica.* TO 'monica'@'%';
FLUSH PRIVILEGES;
```

Detailed instructions in **QUICKSTART.md**.

---

## Support

### For Repository Issues
- GitHub Issues: https://github.com/TheDuke427/gaseous/issues

### For Monica Help  
- Monica Docs: https://docs.monicahq.com/
- Monica GitHub: https://github.com/monicahq/monica

### For Home Assistant
- HA Community: https://community.home-assistant.io/

---

## What Users Get

When users install this add-on:

1. **Automatic Setup** - Database initialization, migrations, key generation
2. **Secure by Default** - Encryption, security headers, access controls
3. **Easy Configuration** - Simple YAML config in Home Assistant
4. **Sidebar Access** - One-click access from HA sidebar
5. **Full Features** - All Monica CRM functionality
6. **Regular Updates** - Easy updates through Home Assistant
7. **Backup Support** - Integrated with HA backup system
8. **Great Docs** - Multiple documentation files for any question

---

## Maintenance

### Updating Monica Version

To update to a newer Monica version:

1. Edit `Dockerfile`
2. Change the git clone branch/tag
3. Update version in `config.yaml`
4. Update `CHANGELOG.md`
5. Commit and push
6. Rebuilds automatically (if using GitHub Actions)

### Supporting New Features

Add new configuration options in:
- `config.yaml` - Schema definition
- `rootfs/etc/cont-init.d/10-monica.sh` - Configuration handling
- `README.md` - User documentation

---

## License

- **This Add-on:** MIT License (free to use, modify, distribute)
- **Monica CRM:** AGPL-3.0 License

---

## Credits

### Monica CRM
- Created by Régis Freyd
- https://github.com/monicahq/monica
- Open source personal relationship manager

### Home Assistant
- By Nabu Casa
- https://www.home-assistant.io/
- Open source home automation

### This Add-on
- Created for TheDuke427
- Based on Monica CRM
- Optimized for Home Assistant

---

## Next Steps

1. ✅ Copy `monica/` folder to your repository
2. ✅ Add `repository.json` to root (if needed)
3. ✅ Commit and push to GitHub
4. ✅ Test installation in Home Assistant
5. ✅ Share with the community!

---

## Need Help?

All documentation is included:

- **Users:** Start with `README.md` or `QUICKSTART.md`
- **Developers:** See `DOCS.md`
- **Setup:** Check `INSTALL.md`
- **Features:** Read `SUMMARY.md`

---

## 🎊 Congratulations!

You now have a complete, professional Home Assistant add-on ready to deploy!

**What makes this special:**

✨ Production-ready code
✨ Comprehensive documentation  
✨ Security best practices
✨ Multi-architecture support
✨ Easy to maintain
✨ User-friendly setup

Enjoy your Monica CRM Home Assistant add-on! 🚀
