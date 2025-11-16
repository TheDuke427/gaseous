# Setup Guide for Publishing Your Blinko Add-on

This guide will help you publish your Blinko Home Assistant add-on to GitHub so others can use it.

## Step 1: Create a GitHub Repository

1. Go to [GitHub](https://github.com) and log in
2. Click the **+** button in the top right, then **New repository**
3. Name it: `hassio-addon-blinko` (or similar)
4. Add a description: "Home Assistant add-on for Blinko - AI-powered note-taking"
5. Choose **Public** (required for Home Assistant add-ons)
6. Click **Create repository**

## Step 2: Prepare the Add-on Files

You need to create this directory structure:

```
hassio-addon-blinko/
├── blinko/
│   ├── config.yaml
│   ├── Dockerfile
│   ├── build.yaml
│   ├── README.md
│   ├── DOCS.md
│   ├── CHANGELOG.md
│   ├── icon.png
│   ├── logo.png
│   ├── rootfs/
│   │   └── etc/
│   │       └── services.d/
│   │           └── blinko/
│   │               ├── run
│   │               └── finish
│   └── translations/
│       └── en.json
├── repository.yaml
└── README.md
```

## Step 3: Create Icon and Logo

You need to create two images:

### icon.png (required)
- **Size**: 512x512 pixels
- **Format**: PNG
- **Content**: A simple icon representing Blinko/notes
- **Suggestion**: Use a note/pencil/lightbulb icon

### logo.png (required)
- **Size**: 512x512 pixels (minimum)
- **Format**: PNG
- **Content**: Same as icon or a more detailed logo

**Tools to create icons:**
- [Canva](https://www.canva.com) - Free, easy to use
- [GIMP](https://www.gimp.org) - Free, open-source
- [Figma](https://www.figma.com) - Free for personal use
- [Icons8](https://icons8.com) - Free icons you can customize

**Quick option:** Use Material Design Icons
1. Go to [Material Design Icons](https://materialdesignicons.com/)
2. Search for "note-text" or "pencil"
3. Download as PNG at 512x512
4. Save as `icon.png` and `logo.png`

## Step 4: Update Repository Configuration

Edit `repository.yaml`:

```yaml
name: Blinko Add-on Repository
url: https://github.com/YOUR_USERNAME/hassio-addon-blinko
maintainer: Your Name <your.email@example.com>
```

Replace:
- `YOUR_USERNAME` with your GitHub username
- `Your Name` with your actual name
- `your.email@example.com` with your email

## Step 5: Upload to GitHub

### Option A: Using GitHub Web Interface

1. In your GitHub repository, click **Add file** → **Upload files**
2. Drag and drop all the add-on files
3. Maintain the directory structure
4. Write a commit message: "Initial commit of Blinko add-on"
5. Click **Commit changes**

### Option B: Using Git Command Line

```bash
# Clone your repository
git clone https://github.com/YOUR_USERNAME/hassio-addon-blinko.git
cd hassio-addon-blinko

# Copy all add-on files into the repository
cp -r /path/to/blinko-addon/* .

# Add, commit, and push
git add .
git commit -m "Initial commit of Blinko add-on"
git push origin main
```

## Step 6: Verify the Repository

Check that your repository has:
- ✅ `repository.yaml` in the root
- ✅ `blinko/config.yaml` exists
- ✅ `blinko/icon.png` exists
- ✅ `blinko/logo.png` exists
- ✅ All other necessary files

## Step 7: Test the Add-on

1. Open Home Assistant
2. Navigate to **Settings** → **Add-ons** → **Add-on Store**
3. Click **⋮** (three dots) → **Repositories**
4. Add: `https://github.com/YOUR_USERNAME/hassio-addon-blinko`
5. Refresh the add-on store
6. Find "Blinko" in the list
7. Install and test it

## Step 8: Create a Release (Optional)

Creating releases helps users track versions:

1. In GitHub, click **Releases** → **Create a new release**
2. Tag version: `v1.0.0`
3. Release title: `Blinko Add-on v1.0.0`
4. Description: Copy from CHANGELOG.md
5. Click **Publish release**

## Step 9: Share Your Add-on

### Add to Home Assistant Community Add-ons

Consider submitting your add-on to the official [Home Assistant Community Add-ons](https://github.com/hassio-addons) repository for wider distribution.

### Share in the Community

Post about your add-on:
- [Home Assistant Community Forum](https://community.home-assistant.io)
- [Home Assistant Reddit](https://reddit.com/r/homeassistant)
- Social media with hashtag #HomeAssistant

### Create a README.md for the Repository

Add this to your repository's root `README.md`:

```markdown
# Blinko Home Assistant Add-on

![Blinko Logo](blinko/logo.png)

## About

This repository contains the Home Assistant add-on for Blinko, an AI-powered personal note-taking tool.

## Installation

1. Navigate to Settings → Add-ons → Add-on Store in Home Assistant
2. Click the menu (⋮) → Repositories
3. Add this repository: `https://github.com/YOUR_USERNAME/hassio-addon-blinko`
4. Install the "Blinko" add-on
5. Configure and start the add-on

## Features

- 🤖 AI-Enhanced Note Retrieval
- 🔒 Complete Data Ownership
- 🚀 Fast and Efficient
- 💡 Markdown Support
- 🔓 Open Source

## Documentation

For detailed documentation, see [DOCS.md](blinko/DOCS.md)

## Support

- [Report Issues](https://github.com/YOUR_USERNAME/hassio-addon-blinko/issues)
- [Home Assistant Forum](https://community.home-assistant.io)

## Credits

This add-on packages [Blinko](https://github.com/blinkospace/blinko) for Home Assistant.
```

## Troubleshooting

### Repository Not Showing in Add-on Store

- Check the URL is correct
- Verify `repository.yaml` is in the root directory
- Make sure the repository is public
- Try refreshing the browser

### Add-on Not Appearing After Adding Repository

- Check `config.yaml` exists in `blinko/` directory
- Verify YAML syntax is correct
- Check browser console for errors
- Wait a minute and refresh

### Installation Errors

- Review the Dockerfile
- Check that all required files exist
- Verify build.yaml has correct base images

## Maintenance

### Updating the Add-on

1. Make changes to the add-on files
2. Update version in `config.yaml`
3. Update `CHANGELOG.md`
4. Commit and push changes
5. Create a new release tag

### Supporting Users

- Monitor GitHub Issues
- Respond to questions promptly
- Keep documentation updated
- Test updates before releasing

## Legal

### License

Choose an appropriate license:
- MIT License (permissive, recommended)
- Apache License 2.0
- GPL v3 (copyleft)

Add a `LICENSE` file to your repository.

### Disclaimer

Add to your README:

```
This add-on is not officially affiliated with Blinko or Home Assistant.
Use at your own risk. Always backup your data before installing.
```

## Next Steps

1. ✅ Create GitHub repository
2. ✅ Create icon and logo images
3. ✅ Upload all files
4. ✅ Test installation
5. ✅ Create release
6. ✅ Share with community
7. ✅ Monitor and maintain

**Congratulations!** Your Blinko add-on is now published and ready for others to use!
