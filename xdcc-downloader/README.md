# 📡 XDCC Downloader for Home Assistant

A modern, web-based XDCC downloader add-on that brings automated IRC file transfers to your Home Assistant setup. Download files from IRC bots with a sleek interface - no terminal required!

## ✨ Features

- 🌐 **Web-based GUI** - Clean, modern interface accessible from anywhere
- 📊 **Real-time Progress Tracking** - Watch your downloads progress with live updates
- 🔄 **Automatic Retries** - Smart retry logic handles connection issues
- 📝 **Detailed Logging** - See exactly what's happening with each download
- 💾 **Direct to Media Drive** - Downloads go straight to your configured storage
- 🚀 **Multi-threaded** - Queue up multiple downloads simultaneously
- 🎯 **Smart DCC Parsing** - Handles various DCC SEND formats automatically

## 🖼️ What It Looks Like

The add-on provides a simple form where you enter:
- IRC server and port
- Your nickname
- The channel name
- The bot name
- The pack number

Hit "Start Download" and watch the magic happen! Progress updates in real-time with detailed logs showing connection status, download speed, and completion.

## 📦 Installation

### Local Add-on Repository

1. Create a new folder in your Home Assistant configuration directory:
   ```
   /addons/xdcc-downloader/
   ```

2. Add these three files to the folder:
   - `Dockerfile`
   - `run.sh`
   - `config.json`

3. Reload Home Assistant add-ons
4. The "XDCC Downloader" add-on will appear in your add-on store
5. Click Install

### From GitHub (if you publish it)

1. Add the repository URL to your Home Assistant add-on store
2. Find "XDCC Downloader" in the add-on list
3. Click Install

## ⚙️ Configuration

The add-on has minimal configuration - just set your download path:

```yaml
download_path: /media/xdcc-downloads
```

**Important**: Make sure the path exists and is writable! The add-on has access to your `/media` directory via the Home Assistant mapping.

### Recommended Paths

- `/media/xdcc-downloads` - Dedicated XDCC folder
- `/media/downloads` - General downloads folder

## 🚀 Usage

1. **Start the add-on** from the Home Assistant UI
2. Click **"OPEN WEB UI"** 
3. Fill in the download form:
   - **IRC Server**: e.g., `irc.rizon.net`, `irc.libera.chat`
   - **Port**: Usually `6667` (standard) or `6697` (SSL)
   - **Nickname**: Your IRC nickname (can be anything)
   - **Channel**: The IRC channel (include the #), e.g., `#ELITEWAREZ`
   - **Bot Name**: The exact bot name (case-sensitive!), e.g., `[EWG]-[TB-IKR09`
   - **Pack Number**: The pack number, e.g., `277`
4. Click **"Start Download"**
5. Watch the progress in real-time!

### Pro Tips

- **Bot names are case-sensitive** - Copy them exactly as they appear in IRC
- **Join the channel first** with The Lounge (or another IRC client) to browse packs
- **Check bot queues** - Some bots have slot limits, the logs will show queue messages
- **Multiple downloads** - You can start multiple downloads at once
- **Refresh file list** - Click the refresh button to see newly completed downloads

## 🔗 Perfect Pairing: The Lounge + XDCC Downloader

This add-on works beautifully alongside **The Lounge** IRC client:

1. Use **The Lounge** to:
   - Browse IRC channels
   - Chat and interact
   - See XDCC pack announcements
   - Get bot names and pack numbers

2. Use **XDCC Downloader** to:
   - Actually download the files
   - Track progress
   - Handle the DCC transfers

Together they give you the complete IRC experience!

## 🛠️ Technical Details

### How It Works

The add-on implements a pure Python IRC client with DCC SEND support:

1. **Connects to IRC server** using standard IRC protocol
2. **Joins the specified channel** to establish presence
3. **Sends XDCC request** via PRIVMSG to the bot
4. **Parses DCC SEND offer** from the bot's response
5. **Establishes DCC connection** to the bot's file server
6. **Downloads the file** with progress tracking and acknowledgments
7. **Saves to your media drive** at the configured path

### Retry Logic

- Attempts connection **3 times** before giving up
- **2-second delay** between retry attempts
- Handles common errors: timeouts, connection refused, connection resets

### Supported DCC Formats

The add-on handles multiple DCC SEND message formats:
- Standard: `DCC SEND filename ip port size`
- Quoted: `DCC SEND "filename with spaces" ip port size`
- Various IRC server formats and encodings

## 🐛 Troubleshooting

### Download shows "failed" immediately

**Check the logs** in the download item - they'll tell you exactly what went wrong:
- **"Connection refused"** - Bot may be at max capacity or have firewall rules
- **"Timeout"** - Bot didn't respond, may be offline or pack doesn't exist
- **"Connection reset"** - Bot closed connection, likely due to queue/slots

### Bot says I'm in a queue

Some bots have slot limits. The logs will show queue messages from the bot. Just wait a bit and try again, or try a different bot.

### Wrong bot name or pack number

Bot names are **case-sensitive**! Double-check the exact spelling. Pack numbers should be numeric only.

### Files not appearing in file list

Click the **"Refresh File List"** button. If still not there, check:
- The download completed successfully (status shows "completed")
- Your configured `download_path` is correct
- The path has write permissions

## 📋 Requirements

- Home Assistant OS or Supervised
- Access to `/media` directory
- Network access to IRC servers (ports 6667, 6697)
- Network access for DCC transfers (dynamic ports)

## 🔐 Security Notes

- The add-on runs in **private mode** - it's only accessible within your Home Assistant network
- Downloads are validated by filesize
- All IRC communication is logged for debugging
- No credentials are stored (IRC is typically anonymous)

## 🎨 Future Enhancements

Possible additions for future versions:
- [ ] Search functionality across multiple bots
- [ ] Queue management and scheduling
- [ ] Bandwidth throttling
- [ ] Notification integration
- [ ] Download history
- [ ] Auto-extraction for archives
- [ ] Integration with download managers

## 🤝 Contributing

Found a bug? Have a feature request? Open an issue or submit a PR!

## 📄 License

MIT License - feel free to modify and distribute!

## 🙏 Credits

Built with ❤️ for the Home Assistant community.

Special thanks to:
- The IRC protocol maintainers
- XDCC bot operators
- Home Assistant developers
- Everyone who still appreciates the classics!

---

**Enjoy your downloads!** 🎉

Remember: Use this responsibly and respect the rules of IRC networks and channels you join.
