# Quick Start - Blinko Home Assistant Add-on

## What You Have

A complete Home Assistant add-on for Blinko with:
- ✅ Full ingress support
- ✅ PostgreSQL database included
- ✅ Multi-architecture support (amd64, aarch64, armv7)
- ✅ Comprehensive documentation
- ✅ Security best practices

## What You Need to Do

### 1. Create Two Images (5 minutes)
**You MUST create these files:**
- `icon.png` - 512x512 pixel PNG
- `logo.png` - 512x512 pixel PNG

**Easiest way:**
1. Go to https://materialdesignicons.com/
2. Search "note-text"
3. Download as PNG at 512x512
4. Save as both `icon.png` and `logo.png`

### 2. Set Up GitHub (10 minutes)
```bash
# Create repo on GitHub: hassio-addon-blinko (must be public)

# Clone and add files
git clone https://github.com/YOUR_USERNAME/hassio-addon-blinko.git
cd hassio-addon-blinko
cp -r /path/to/blinko-addon/* .

# Add your icons
cp /path/to/icon.png .
cp /path/to/logo.png .

# Update repository.yaml with your info
# Update README.md URLs

# Push to GitHub
git add .
git commit -m "Initial commit"
git push origin main
```

### 3. Install in Home Assistant (5 minutes)
1. Settings → Add-ons → Add-on Store
2. ⋮ → Repositories
3. Add: `https://github.com/YOUR_USERNAME/hassio-addon-blinko`
4. Find "Blinko" and click Install

### 4. Configure (2 minutes)
Generate secrets:
```bash
openssl rand -base64 32  # postgres_password
openssl rand -base64 32  # nextauth_secret
```

Add to configuration and click Save.

### 5. Start (1 minute)
1. Click Start
2. Wait for startup
3. Click "Blinko" in sidebar
4. Login (username: `blinko`, password: `blinko`)
5. Change password immediately!

## Total Time: ~25 minutes

## Key Files

| File | Purpose |
|------|---------|
| `config.yaml` | Add-on configuration & ingress setup |
| `rootfs/etc/services.d/blinko/run` | Startup script |
| `docker-compose.yml` | Service orchestration |
| `README.md` | User documentation |
| `DOCS.md` | Detailed usage guide |

## Important Notes

⚠️ **Must Do:**
- Create icon.png and logo.png (not optional!)
- Set secure passwords in configuration
- Change default Blinko password after first login

✅ **Good to Know:**
- Ingress works automatically (no port forwarding needed)
- Data stored in `/addon_config/` directory
- Backups included in Home Assistant backups
- PostgreSQL runs in separate container

## Getting Help

📖 **Documentation:**
- `SETUP_CHECKLIST.md` - Step-by-step checklist
- `INSTALLATION.md` - Detailed install guide
- `DOCS.md` - Complete documentation
- `SETUP_GUIDE.md` - Publishing guide

🐛 **Troubleshooting:**
- Check add-on logs: Settings → Add-ons → Blinko → Log
- Verify configuration is correct
- Ensure icons are PNG and 512x512
- Make sure repository is public

🆘 **Support:**
- Blinko issues: https://github.com/blinkospace/blinko/issues
- Home Assistant forum: https://community.home-assistant.io

## Success Looks Like

When everything works:
1. ✅ "Blinko" appears in your HA sidebar
2. ✅ Clicking it opens the Blinko interface
3. ✅ You can create and save notes
4. ✅ Notes persist after restart
5. ✅ Search and AI features work

## Common Issues

**"Add-on not in store"**
→ Verify repository is public and URL is correct

**"Can't find icon.png"**
→ You need to create actual PNG files, not .txt placeholders

**"Add-on won't start"**
→ Check that both secrets are configured

**"Can't access via ingress"**
→ Ensure add-on shows "Running" status

## Next Steps After Setup

1. 📝 Create your first notes
2. 🏷️ Experiment with tags (`#tag` syntax)
3. 🤖 Try AI-powered search
4. 💾 Set up regular backups
5. 🎨 Customize Blinko settings
6. 🌐 Share your repository (optional)

---

**Ready? Start with SETUP_CHECKLIST.md for the complete walkthrough!**

Good luck! 🚀
