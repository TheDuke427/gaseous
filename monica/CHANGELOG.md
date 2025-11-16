# Changelog

All notable changes to this add-on will be documented in this file.

## [4.1.2] - 2025-11-16

### Added
- Initial release of Monica Home Assistant Add-on
- Full ingress support for sidebar integration
- MariaDB integration for data persistence
- Support for all major architectures (amd64, aarch64, armhf, armv7, i386)
- Automatic database initialization and migrations
- Configurable SMTP mail support
- Environment-based configuration
- Security headers and optimized nginx configuration
- Comprehensive documentation

### Features
- Personal relationship management
- Contact database with custom fields
- Birthday and event reminders
- Activity and conversation logging
- Journal/diary functionality
- Document and photo uploads
- Multi-user support with access control
- CardDAV support for contact synchronization
- Mobile-responsive interface

### Technical Details
- Based on Monica CRM 4.x branch
- PHP 8.2 with FPM
- Nginx web server
- Compatible with Home Assistant MariaDB add-on
- Persistent storage for user data
- Automatic application key generation
- Database migration on startup

## Security

### Security Measures
- Secure application key generation
- Password hashing with bcrypt
- HTTPS support through Home Assistant ingress
- XSS and CSRF protection
- SQL injection prevention via prepared statements
- Configurable signup restrictions
- Trusted proxy configuration for ingress

## Known Issues

None at this time.

## Planned Features

- [ ] Automatic backup scheduling
- [ ] Redis cache support for improved performance
- [ ] Cron job support for scheduled tasks
- [ ] CalDAV/CardDAV proxy configuration
- [ ] Import/export tools for migrations
- [ ] Multi-language support in add-on interface

## Support

For bug reports and feature requests, please open an issue on the [GitHub repository](https://github.com/TheDuke427/gaseous/issues).
