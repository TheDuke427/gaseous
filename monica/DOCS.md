# Monica Home Assistant Add-on - Developer Documentation

## Architecture

This add-on packages Monica CRM as a Home Assistant add-on with the following components:

### Components

1. **Nginx** - Web server serving Monica's public files
2. **PHP-FPM 8.2** - PHP FastCGI Process Manager for running Laravel/Monica
3. **Monica CRM** - Laravel-based personal relationship management application
4. **MariaDB** (external) - Database server provided by Home Assistant add-on

### Directory Structure

```
monica/
├── config.yaml           # Add-on configuration schema
├── build.yaml           # Build configuration for multiple architectures
├── Dockerfile           # Container image definition
├── README.md            # User documentation
├── CHANGELOG.md         # Version history
├── DOCS.md              # Additional documentation
├── icon.json            # Add-on icon metadata
├── logo.svg             # Add-on logo
└── rootfs/              # Root filesystem overlay
    └── etc/
        ├── cont-init.d/              # Initialization scripts
        │   └── 10-monica.sh          # Monica setup script
        ├── services.d/               # Service runners
        │   ├── nginx/
        │   │   └── run               # Nginx service
        │   └── php-fpm/
        │       └── run               # PHP-FPM service
        └── nginx/
            ├── nginx.conf            # Main nginx config
            └── templates/
                └── monica.conf.template  # Site config template
```

## Build Process

### Base Image

The add-on uses the Home Assistant base images which provide:
- S6 overlay for process supervision
- Bashio for configuration handling
- Common utilities and libraries

### Build Steps

1. Install system packages (nginx, PHP, composer, etc.)
2. Clone Monica repository (4.x branch)
3. Install PHP dependencies via Composer
4. Configure PHP-FPM and nginx
5. Copy rootfs overlay
6. Set permissions

### Multi-Architecture Support

The add-on supports:
- `amd64` - x86-64 systems
- `aarch64` - ARM 64-bit (Raspberry Pi 4, etc.)
- `armhf` - ARM hard-float
- `armv7` - ARM v7
- `i386` - 32-bit x86

## Initialization Process

### Startup Sequence

1. **S6 starts** - Process supervision begins
2. **cont-init.d scripts run** - Configuration setup
   - `10-monica.sh` executes
3. **Services start** - nginx and PHP-FPM start

### 10-monica.sh Script

This script handles:

1. **Configuration Loading**
   - Reads add-on configuration via bashio
   - Gets database credentials
   - Determines ingress URL

2. **Database Preparation**
   - Waits for MariaDB to be ready (max 60 seconds)
   - Creates database if it doesn't exist
   - Verifies connection

3. **Application Key**
   - Generates or loads APP_KEY
   - Stores in `/data/.app_key` for persistence

4. **Environment Configuration**
   - Creates `.env` file with all settings
   - Configures database connection
   - Sets up mail settings
   - Enables ingress proxy support

5. **Database Initialization**
   - Checks if database is empty
   - Runs migrations and seeders if needed
   - Sets up Passport for API authentication
   - Creates storage symlinks

6. **Permissions**
   - Sets correct ownership (nginx:nginx)
   - Sets directory permissions

7. **Web Server Configuration**
   - Processes nginx template with ingress path
   - Enables site configuration

## Ingress Support

### How It Works

Home Assistant Ingress provides:
- Automatic SSL termination
- Authentication integration
- Sidebar access
- Path-based routing

### Implementation

The add-on supports ingress through:

1. **Configuration** (`config.yaml`):
   ```yaml
   ingress: true
   ingress_port: 80
   ```

2. **Nginx Configuration**:
   - Accepts requests on ingress path
   - Forwards to PHP-FPM
   - Sets required headers for Laravel

3. **Laravel Configuration**:
   - `TRUSTED_PROXIES=*` - Trust ingress proxy
   - `APP_URL` set to ingress URL
   - Headers passed for scheme detection

### URL Structure

- **Ingress**: `https://homeassistant.local/api/hassio_ingress/<token>/`
- **Direct**: `http://homeassistant.local:PORT/`

## Database Schema

Monica uses a complex database schema with tables for:

- Users and authentication
- Contacts and relationships
- Activities and conversations
- Reminders and notifications
- Journal entries
- Documents and photos
- Settings and preferences

The schema is managed by Laravel migrations in Monica's codebase.

## Configuration Options

### Database Connection

Monica connects to MariaDB using:
```php
DB_CONNECTION=mysql
DB_HOST=<from config>
DB_PORT=<from config>
DB_DATABASE=<from config>
DB_USERNAME=<from config>
DB_PASSWORD=<from config>
```

### Application Settings

Key environment variables:
- `APP_KEY` - Encryption key (auto-generated)
- `APP_ENV` - Environment (production/local)
- `APP_URL` - Application URL (auto-set for ingress)
- `APP_DISABLE_SIGNUP` - Disable new registrations

### Security Settings

- `TRUSTED_PROXIES=*` - Required for ingress
- `HASH_SALT` - Password hashing salt (auto-generated)
- `CHECK_VERSION=false` - Disable external version checks

## Troubleshooting

### Common Issues

1. **Database Connection Fails**
   - Check MariaDB is running
   - Verify credentials
   - Check network connectivity
   - Look for firewall issues

2. **Ingress Not Working**
   - Verify ingress is enabled
   - Check nginx configuration
   - Review Home Assistant logs
   - Test direct port access

3. **Migrations Fail**
   - Check database permissions
   - Verify database charset (utf8mb4)
   - Review Monica logs
   - Check disk space

4. **PHP Errors**
   - Check PHP-FPM logs
   - Verify PHP extensions installed
   - Check file permissions
   - Review memory limits

### Debug Mode

To enable debug mode:
1. Edit `10-monica.sh`
2. Set `APP_DEBUG=true` in .env
3. Restart add-on
4. Check logs for detailed errors

## Updating

### Monica Updates

To update Monica version:
1. Edit `Dockerfile`
2. Change git branch/tag
3. Rebuild add-on
4. Update version in `config.yaml`

### Add-on Updates

To update add-on:
1. Make changes to code
2. Update version in `config.yaml`
3. Update `CHANGELOG.md`
4. Push to repository
5. Users can update via add-on store

## Testing

### Local Testing

1. **Build the image**:
   ```bash
   docker build -t monica-addon .
   ```

2. **Run locally**:
   ```bash
   docker run -it --rm \
     -e DB_HOST=mariadb \
     -e DB_PORT=3306 \
     -e DB_NAME=monica \
     -e DB_USER=monica \
     -e DB_PASSWORD=password \
     monica-addon
   ```

3. **Test ingress**:
   - Use Home Assistant dev environment
   - Enable add-on in supervisor
   - Test via ingress panel

### Integration Testing

Test scenarios:
- Fresh installation
- Database migration
- Upgrade from previous version
- Different architectures
- Various database configurations

## Performance Optimization

### PHP-FPM

Current settings:
- Process manager: dynamic
- Max children: based on available memory
- Memory limit: 512M

### Nginx

Optimizations:
- Gzip compression enabled
- Static file caching
- FastCGI caching (optional)
- Connection keepalive

### Database

Recommendations:
- Regular OPTIMIZE TABLE
- Index maintenance
- Query monitoring
- Connection pooling

## Security Considerations

### Best Practices

1. **Database Credentials**
   - Use strong passwords
   - Limit access to localhost
   - Regular password rotation

2. **Application Security**
   - Keep Monica updated
   - Monitor security advisories
   - Regular backups
   - Enable MFA

3. **Network Security**
   - Use ingress (built-in SSL)
   - Firewall configuration
   - VPN for remote access

### Security Headers

Nginx adds:
- `X-Frame-Options: SAMEORIGIN`
- `X-XSS-Protection: 1; mode=block`
- `X-Content-Type-Options: nosniff`
- `Referrer-Policy: no-referrer-when-downgrade`

## Contributing

### Code Style

- Follow existing patterns
- Comment complex logic
- Use descriptive variable names
- Test thoroughly

### Pull Requests

1. Fork repository
2. Create feature branch
3. Make changes
4. Test locally
5. Submit PR with description

### Issue Reporting

Include:
- Add-on version
- Home Assistant version
- Architecture
- Logs
- Steps to reproduce

## License

This add-on is released under the MIT License. Monica CRM is licensed under AGPL-3.0.

## Credits

- Monica CRM by Régis Freyd
- Home Assistant by Nabu Casa
- Community contributors

## Resources

- [Monica Documentation](https://docs.monicahq.com/)
- [Home Assistant Add-on Documentation](https://developers.home-assistant.io/docs/add-ons)
- [Laravel Documentation](https://laravel.com/docs)
