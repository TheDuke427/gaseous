# Monica Home Assistant Add-on - Complete Summary

## Overview

This is a fully functional Home Assistant add-on for **Monica Personal CRM** - an open-source personal relationship management tool. The add-on is designed to integrate seamlessly with Home Assistant's ingress system for sidebar access and uses your existing MariaDB add-on for data persistence.

## What's Included

### Core Files

1. **config.yaml** - Add-on configuration schema
   - Defines all configuration options
   - Sets ingress support
   - Specifies supported architectures
   - Defines ports and authentication

2. **build.yaml** - Build configuration
   - Multi-architecture support (amd64, aarch64, armhf, armv7, i386)
   - Base image specifications
   - Build labels

3. **Dockerfile** - Container definition
   - Based on Home Assistant base images
   - Installs Nginx, PHP 8.2, and dependencies
   - Clones Monica 4.x from GitHub
   - Configures PHP-FPM and web server
   - Sets up proper permissions

### Runtime Files (rootfs/)

4. **10-monica.sh** - Initialization script
   - Configures Monica from Home Assistant config
   - Generates secure APP_KEY
   - Creates .env file with all settings
   - Waits for MariaDB readiness
   - Creates database if needed
   - Runs migrations on first start
   - Sets up ingress URLs
   - Configures permissions

5. **nginx/run** - Nginx service runner
   - Starts and monitors web server

6. **php-fpm/run** - PHP-FPM service runner
   - Starts and monitors PHP processor

7. **nginx.conf** - Nginx main configuration
   - Optimized for performance
   - Gzip compression enabled
   - Security headers

8. **monica.conf.template** - Site configuration
   - Ingress path support
   - FastCGI configuration
   - Security rules
   - Static file handling

### Documentation

9. **README.md** - User documentation
   - Feature overview
   - Installation instructions
   - Configuration guide
   - SMTP setup examples
   - Troubleshooting
   - Backup/restore procedures

10. **QUICKSTART.md** - Quick setup guide
    - Step-by-step installation
    - Database setup commands
    - Common first-time issues
    - Initial configuration tips

11. **DOCS.md** - Developer documentation
    - Architecture overview
    - Build process details
    - Initialization sequence
    - Ingress implementation
    - Testing procedures
    - Performance optimization

12. **INSTALL.md** - Repository setup guide
    - How to add to GitHub
    - GitHub Actions configuration
    - User installation steps
    - Build troubleshooting

13. **CHANGELOG.md** - Version history
    - All changes documented
    - Features and fixes
    - Known issues
    - Planned features

### Assets

14. **icon.json** - Add-on icon metadata
15. **logo.svg** - Add-on logo graphic
16. **.gitignore** - Git ignore rules

## Key Features

### ✅ Home Assistant Integration
- **Ingress Support** - Access from sidebar with SSL and authentication
- **Configuration Integration** - Uses Home Assistant config system
- **MariaDB Integration** - Works with existing MariaDB add-on
- **Multi-Architecture** - Supports all major platforms

### ✅ Security
- Automatic APP_KEY generation and persistence
- Secure password hashing
- HTTPS via ingress
- XSS and CSRF protection
- Configurable signup restrictions
- Trusted proxy configuration

### ✅ Ease of Use
- Automatic database initialization
- Self-configuring for ingress
- Migration handling on updates
- Clear error messages
- Comprehensive logging

### ✅ Monica Features
All standard Monica CRM features:
- Contact management
- Relationship tracking
- Birthday reminders
- Activity logging
- Journal/diary
- Document uploads
- Task management
- Email reminders (with SMTP)
- CardDAV support
- Multi-user support

## Technical Stack

- **Web Server:** Nginx
- **Application:** Monica CRM 4.x (Laravel-based)
- **PHP:** 8.2 with FPM
- **Database:** MariaDB (external)
- **Base:** Home Assistant Add-on Base Images
- **Process Supervision:** S6 Overlay

## Configuration Example

```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "secure_password_here"
app_env: production
app_disable_signup: true
mail_mailer: smtp
mail_host: smtp.gmail.com
mail_port: 587
mail_username: your-email@gmail.com
mail_password: your-app-password
mail_encryption: tls
mail_from_address: your-email@gmail.com
mail_from_name: Monica
```

## Installation Process

### Prerequisites
1. Home Assistant installed
2. MariaDB add-on running
3. Database created for Monica

### Steps
1. Add repository to Home Assistant
2. Install Monica add-on
3. Configure database settings
4. Start add-on
5. Access via sidebar
6. Create first user account
7. Disable signups for security

## Architecture

```
┌─────────────────────────────────────┐
│     Home Assistant Ingress          │
│  (SSL, Auth, Path Routing)          │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│         Nginx Web Server            │
│  (Port 80, FastCGI Proxy)           │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│          PHP-FPM 8.2                │
│   (Monica Laravel Application)      │
└──────────────┬──────────────────────┘
               │
               ▼
┌─────────────────────────────────────┐
│      MariaDB Database               │
│    (core-mariadb add-on)            │
└─────────────────────────────────────┘
```

## Data Persistence

- **Database:** Stored in MariaDB (persists across restarts)
- **APP_KEY:** Stored in `/data/.app_key` (persists across updates)
- **Uploads:** Stored in database (included in backups)
- **Configuration:** Stored in Home Assistant config

## Backup Strategy

1. **Database Backup:**
   - Include in Home Assistant backups
   - Or use mysqldump for manual backups
   - Export: `mysqldump -u monica -p monica > backup.sql`

2. **Configuration Backup:**
   - Included in Home Assistant snapshots
   - Note APP_KEY if rebuilding

3. **Restore Process:**
   - Restore database
   - Reinstall add-on with same config
   - Add-on will detect existing database

## Troubleshooting

### Common Issues

1. **Can't Connect to Database**
   - ✅ Verify MariaDB is running
   - ✅ Check credentials
   - ✅ Ensure database exists

2. **Ingress Not Working**
   - ✅ Verify ingress enabled
   - ✅ Try direct port
   - ✅ Check HA logs

3. **Can't Create Account**
   - ✅ Set `app_disable_signup: false`
   - ✅ Restart add-on
   - ✅ Clear browser cache

### Debug Steps

1. Check add-on logs
2. Verify database connection
3. Test with direct port access
4. Review nginx error logs
5. Check PHP-FPM logs

## Performance

### Expected Resource Usage
- **CPU:** Low (idle) to Medium (active use)
- **Memory:** ~200-300MB base + user data
- **Disk:** Varies based on uploaded content
- **Network:** Minimal

### Optimization Tips
- Regular database optimization
- Limit file upload sizes
- Use external SMTP for emails
- Monitor disk usage

## Maintenance

### Regular Tasks
- Weekly: Update contacts
- Monthly: Check for updates
- Monthly: Verify backups work
- Quarterly: Database optimization
- Yearly: Review/clean old data

### Updates
- Automatic notifications in HA
- Backup before updating
- Read changelog first
- Test in dev environment if possible

## Future Enhancements

Potential improvements:
- Redis caching support
- Cron job scheduling
- CalDAV proxy configuration
- Automated backups
- Import/export tools
- Multi-language UI
- Performance monitoring

## Support & Resources

### Get Help
- **GitHub Issues:** https://github.com/TheDuke427/gaseous/issues
- **Monica Docs:** https://docs.monicahq.com/
- **HA Community:** https://community.home-assistant.io/

### Contributing
Contributions welcome! See DOCS.md for developer info.

### License
- Add-on: MIT License
- Monica CRM: AGPL-3.0 License

## Credits

- **Monica CRM:** Régis Freyd and contributors
- **Add-on Development:** TheDuke427
- **Home Assistant:** Nabu Casa and community

## Conclusion

This add-on provides a production-ready, secure, and fully-featured Monica CRM installation for Home Assistant. It's designed to be:

- **Easy to install** - Simple configuration, automatic setup
- **Secure** - Built-in security features and best practices
- **Reliable** - Proper error handling and logging
- **Maintainable** - Clear documentation and update path
- **Integrated** - Works seamlessly with Home Assistant

Perfect for anyone wanting to manage personal relationships alongside their smart home! 🏠❤️
