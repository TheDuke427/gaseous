# Audiobookshelf Home Assistant Add-on

[![Audiobookshelf](https://raw.githubusercontent.com/advplyr/audiobookshelf/master/client/static/Logo.png)](https://www.audiobookshelf.org/)

Transform your Home Assistant into a powerful self-hosted audiobook and podcast server! 🎧📚

## About

Audiobookshelf is a self-hosted audiobook and podcast server that helps you organize and enjoy your audio content. This add-on brings the full power of Audiobookshelf directly into your Home Assistant ecosystem.

### Features ✨

- **Beautiful Web Interface** - Modern, responsive UI for managing your library
- **Mobile Apps** - Native Android and iOS apps with offline listening
- **Smart Organization** - Automatically organize audiobooks by series, author, and narrator
- **Podcast Support** - Subscribe to and auto-download podcast episodes
- **Progress Tracking** - Syncs your listening progress across all devices
- **Multiple Users** - Create accounts with custom permissions for family members
- **Ebook Support** - Read EPUBs, PDFs, CBR, and CBZ files
- **Send to Device** - Send ebooks directly to your Kindle
- **Chapter Support** - Navigate chapters with ease
- **Sleep Timer** - Built-in sleep timer for bedtime listening
- **Playback Speed Control** - Adjust playback speed to your preference

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "Audiobookshelf" add-on
3. Start the add-on
4. Navigate to `http://homeassistant.local:13378`
5. Create your admin account

## Configuration

### Default Port

The web interface is available on port **13378** by default.

### Storage Locations

The add-on automatically maps these directories:

- **`/share`** - Access to your Home Assistant shared folder
- **`/media`** - Access to your media folder
- **`/config`** - Persistent configuration and database storage

### Setting Up Your Library

1. Open Audiobookshelf at `http://homeassistant.local:13378`
2. Log in with your admin account
3. Click **"Libraries"** → **"Add Library"**
4. Choose your library type (Audiobooks or Podcasts)
5. Select the folder where your media is stored (e.g., `/media/audiobooks`)
6. Click **"Create"**

## Folder Structure

For best results, organize your audiobooks like this:

```
/media/audiobooks/
├── Author Name/
│   ├── Book Title/
│   │   ├── book.m4b
│   │   └── cover.jpg
│   └── Series Name/
│       ├── 01 - First Book/
│       │   └── book.m4b
│       ├── 02 - Second Book/
│       │   └── book.m4b
```

**Key Points:**
- Each audiobook should be in its own folder
- Audio files can be MP3, M4B, M4A, FLAC, OGG, AAC, or WAV
- Include cover.jpg for custom artwork
- Use numbered prefixes (01, 02) for series books

## Mobile Apps

Download the Audiobookshelf app:

- **Android**: [Google Play Store](https://play.google.com/store/apps/details?id=com.audiobookshelf.app)
- **iOS**: [TestFlight Beta](https://testflight.apple.com/join/wiic7QIW)

Connect to your server:
1. Open the app
2. Enter your server address: `http://[your-home-assistant-ip]:13378`
3. Log in with your credentials

## Tips & Tricks

### Metadata Management
Audiobookshelf can automatically fetch metadata and cover art from online sources. Click the edit button on any book to match metadata or manually edit details.

### Series Organization
Group books into series by:
1. Editing each book
2. Adding the series name
3. Setting the sequence number

### Backup Your Library
Your configuration and progress data is stored in `/config`. Back this up regularly to preserve your library settings and listening progress!

### Performance
For large libraries (1000+ books), consider:
- Enabling metadata caching
- Using M4B format (single file per book)
- Adding books gradually and scanning in batches

## Troubleshooting

### Books Not Appearing
1. Check folder permissions
2. Run **"Scan Library"** from the library settings
3. Verify your folder structure matches the recommended format

### Can't Connect to Web Interface
- Verify the add-on is running
- Check that port 13378 isn't blocked by your firewall
- Try accessing via IP: `http://192.168.x.x:13378`

### Series Not Showing Up
- Ensure all books in a series are in one parent folder
- Use **"Match All"** to auto-detect series from metadata
- Manually set series information in book details

## Support

- **Audiobookshelf Documentation**: https://www.audiobookshelf.org/docs
- **Audiobookshelf GitHub**: https://github.com/advplyr/audiobookshelf
- **Discord Community**: https://discord.gg/audiobookshelf

## Version

Current version: **2.17.4**

## Credits

This add-on packages the excellent [Audiobookshelf](https://github.com/advplyr/audiobookshelf) project by [@advplyr](https://github.com/advplyr) for easy deployment in Home Assistant.

---

**Happy Listening!** 🎧
