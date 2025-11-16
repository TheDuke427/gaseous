# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2024-01-XX

### Added
- Initial release of Blinko Home Assistant Add-on
- PostgreSQL 14 database integration
- Blinko web application with AI-powered note-taking
- Ingress support for seamless Home Assistant integration
- Configurable timezone support
- Secure password configuration for database and authentication
- Persistent data storage
- Multi-architecture support (aarch64, amd64, armhf, armv7, i386)
- Comprehensive documentation and setup guide
- Automatic database initialization
- Health checks for both PostgreSQL and Blinko services

### Security
- Mandatory password configuration for PostgreSQL
- NextAuth secret key requirement (minimum 32 characters)
- Ingress-first approach for secure access
