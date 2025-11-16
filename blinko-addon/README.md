# Home Assistant Add-on: Blinko

![Supports aarch64 Architecture][aarch64-shield]
![Supports amd64 Architecture][amd64-shield]
![Supports armhf Architecture][armhf-shield]
![Supports armv7 Architecture][armv7-shield]
![Supports i386 Architecture][i386-shield]

Blinko is an AI-powered note-taking tool designed for individuals who want to quickly capture and organize their fleeting thoughts. With Blinko, you can seamlessly jot down ideas the moment they strike, ensuring that no spark of creativity is lost.

## About

Blinko offers several powerful features:

- **🤖 AI-Enhanced Note Retrieval**: With Blinko's advanced AI-powered RAG (Retrieval-Augmented Generation), you can quickly search and access your notes using natural language queries
- **🔒 Data Ownership**: Your privacy matters. All your notes and data are stored securely in your self-hosted environment
- **🚀 Efficient and Fast**: Capture ideas instantly with full Markdown support for quick formatting and seamless sharing
- **💡 Lightweight Architecture**: Built with modern technologies for robust performance while maintaining exceptional speed and efficiency
- **🔓 Open Source**: Transparent and available on GitHub, fostering collaboration and constant improvement

This add-on includes:
- Blinko web application
- PostgreSQL database for data storage
- Ingress support for seamless Home Assistant integration

## Installation

1. Add this repository to your Home Assistant add-on store
2. Click on "Blinko" in the add-on store
3. Click "Install"
4. Configure the add-on (see Configuration section)
5. Click "Start"
6. Access Blinko through the Home Assistant sidebar (Ingress) or via the port if configured

## Configuration

### Required Configuration

Before starting the add-on, you **must** change the default passwords:

```yaml
postgres_password: "your_secure_postgres_password"
nextauth_secret: "your_secure_nextauth_secret_minimum_32_characters"
timezone: "America/New_York"
```

#### Configuration Options

| Option | Description | Default |
|--------|-------------|---------|
| `postgres_password` | Password for the PostgreSQL database | `changeme_postgres_password` |
| `nextauth_secret` | Secret key for NextAuth authentication (minimum 32 characters) | `changeme_nextauth_secret_min_32_chars` |
| `timezone` | Timezone for the application (e.g., America/New_York, Europe/London) | `America/New_York` |

⚠️ **Security Warning**: Make sure to change both `postgres_password` and `nextauth_secret` to secure, random values before starting the add-on!

### Example Configuration

```yaml
postgres_password: "MyS3cur3P0stgr3sP@ssw0rd!"
nextauth_secret: "a_very_long_random_secret_key_with_at_least_32_characters_12345"
timezone: "Europe/London"
```

## Usage

### Accessing Blinko

After installation and configuration:

1. **Via Ingress (Recommended)**: Click on "Blinko" in your Home Assistant sidebar. This is the easiest and most secure method.
2. **Via Port**: If you've exposed port 1111, access Blinko at `http://homeassistant.local:1111` (or your Home Assistant IP address)

### First Login

On first access, you'll need to create an account:
- Navigate to the Blinko interface
- Create your user account
- Start capturing your thoughts!

### Creating Notes

1. Click the "New Note" button
2. Type your idea or thought
3. Add tags using `#tag` syntax
4. Use Markdown for formatting
5. Save your note

### AI-Powered Search

- Enter natural language queries in the search bar
- Blinko will use AI to find relevant notes
- Results are ranked by relevance

## Data Storage

All data is stored persistently in the `/data` directory:
- PostgreSQL data: `/data/postgres`
- Blinko app data: `/data/blinko`

Your data persists across add-on restarts and updates.

## Support

For issues and feature requests:
- Home Assistant Community Forum
- [Blinko GitHub Repository](https://github.com/blinkospace/blinko)

## Changelog & Releases

This add-on follows [Semantic Versioning](https://semver.org/).

## License

MIT License

Copyright (c) 2024 Blinko Space

---

[aarch64-shield]: https://img.shields.io/badge/aarch64-yes-green.svg
[amd64-shield]: https://img.shields.io/badge/amd64-yes-green.svg
[armhf-shield]: https://img.shields.io/badge/armhf-yes-green.svg
[armv7-shield]: https://img.shields.io/badge/armv7-yes-green.svg
[i386-shield]: https://img.shields.io/badge/i386-yes-green.svg
