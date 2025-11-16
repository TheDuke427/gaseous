# Setup Checklist for Blinko Home Assistant Add-on

Use this checklist to ensure you've completed all necessary steps.

## Pre-Setup
- [ ] Review all documentation files
- [ ] Understand Home Assistant add-on structure
- [ ] Have GitHub account ready
- [ ] Have image editing tool available (for icons)

## 1. Create Icons (REQUIRED)
- [ ] Create icon.png (512x512 pixels)
- [ ] Create logo.png (512x512 pixels)
- [ ] Place both in the blinko-addon directory
- [ ] Verify images are exactly 512x512 pixels
- [ ] Verify images are PNG format

### Icon Creation Resources
- Material Design Icons: https://materialdesignicons.com/
- Canva (free): https://www.canva.com
- GIMP (free): https://www.gimp.org
- Figma (free): https://www.figma.com

## 2. Set Up GitHub Repository
- [ ] Create new GitHub repository
  - Name: `hassio-addon-blinko` (or similar)
  - Visibility: **Public** (required for HA add-ons)
  - Initialize: No README, .gitignore, or license (we have our own)
  
- [ ] Clone repository to local machine
  ```bash
  git clone https://github.com/YOUR_USERNAME/hassio-addon-blinko.git
  ```

- [ ] Copy all add-on files to repository
  ```bash
  cp -r blinko-addon/* hassio-addon-blinko/
  ```

## 3. Customize Configuration Files

### repository.yaml
- [ ] Update `url` with your GitHub repository URL
- [ ] Update `maintainer` with your name and email

### README.md
- [ ] Replace `YOUR_USERNAME` with your GitHub username (multiple places)
- [ ] Update support links if desired
- [ ] Add any additional information about your setup

### Other Files (Optional)
- [ ] Review DOCS.md - update if needed
- [ ] Review INSTALLATION.md - update if needed
- [ ] Check all other documentation files

## 4. Commit and Push to GitHub
- [ ] Add all files to git
  ```bash
  cd hassio-addon-blinko
  git add .
  ```

- [ ] Commit changes
  ```bash
  git commit -m "Initial commit of Blinko add-on with ingress support"
  ```

- [ ] Push to GitHub
  ```bash
  git push origin main
  ```

- [ ] Verify all files appear on GitHub

## 5. Verify Repository Structure

Check that your GitHub repository has:
- [ ] `blinko/config.yaml` exists
- [ ] `blinko/Dockerfile` exists
- [ ] `blinko/build.yaml` exists
- [ ] `blinko/icon.png` exists (not .txt file)
- [ ] `blinko/logo.png` exists (not .txt file)
- [ ] `blinko/rootfs/` directory exists
- [ ] `repository.yaml` in root directory
- [ ] `README.md` in root directory

## 6. Test Installation in Home Assistant

### Add Repository
- [ ] Open Home Assistant
- [ ] Navigate to Settings → Add-ons → Add-on Store
- [ ] Click ⋮ (three dots) → Repositories
- [ ] Add repository URL: `https://github.com/YOUR_USERNAME/hassio-addon-blinko`
- [ ] Click Add
- [ ] Click Close

### Install Add-on
- [ ] Refresh the Add-on Store page
- [ ] Locate "Blinko" in the add-on list
- [ ] Click on Blinko
- [ ] Click Install
- [ ] Wait for installation to complete (may take several minutes)

## 7. Configure Add-on

### Generate Secrets
- [ ] Generate postgres_password
  ```bash
  openssl rand -base64 32
  ```
- [ ] Generate nextauth_secret
  ```bash
  openssl rand -base64 32
  ```

### Configure in Home Assistant
- [ ] Go to Configuration tab in add-on
- [ ] Add `postgres_password` (paste generated value)
- [ ] Add `nextauth_secret` (paste generated value)
- [ ] Leave other values as defaults (or customize if needed)
- [ ] Click Save

## 8. Start and Test Add-on

### Start Add-on
- [ ] Click on Info tab
- [ ] Toggle "Start on boot" (recommended)
- [ ] Click Start
- [ ] Monitor Log tab for startup messages
- [ ] Wait for "Blinko is now running!" message

### Test Access
- [ ] Look for "Blinko" in Home Assistant sidebar
- [ ] Click on Blinko sidebar entry
- [ ] Verify Blinko interface loads
- [ ] Test login with default credentials:
  - Username: `blinko`
  - Password: `blinko`

### Test Functionality
- [ ] Change default password immediately after login
- [ ] Create a test note
- [ ] Try searching for the note
- [ ] Add some tags
- [ ] Verify data persists after add-on restart

## 9. Create Backup
- [ ] Navigate to Settings → System → Backups
- [ ] Create Full Backup or Partial Backup (include add-ons)
- [ ] Verify backup completes successfully

## 10. Optional: Create GitHub Release
- [ ] Go to your repository on GitHub
- [ ] Click Releases → Create a new release
- [ ] Tag: `v1.0.0`
- [ ] Title: "Blinko Add-on v1.0.0"
- [ ] Description: Copy from CHANGELOG.md
- [ ] Click Publish release

## 11. Share Your Add-on (Optional)

### Community Forums
- [ ] Post on Home Assistant Community Forum
- [ ] Share on r/homeassistant subreddit
- [ ] Share on social media with #HomeAssistant

### Documentation
- [ ] Ensure README.md is clear and helpful
- [ ] Consider adding screenshots
- [ ] Add FAQ section if needed

## 12. Maintenance Plan
- [ ] Set up GitHub Issues for bug reports
- [ ] Plan to monitor repository regularly
- [ ] Keep up with Blinko updates
- [ ] Update add-on when new Blinko versions release

## Troubleshooting Checklist

If something doesn't work:

### Repository Issues
- [ ] Verify repository is public
- [ ] Check repository.yaml exists in root
- [ ] Verify all paths are correct
- [ ] Check YAML syntax is valid

### Icon Issues
- [ ] Confirm icons are PNG format
- [ ] Verify icons are exactly 512x512 pixels
- [ ] Ensure files are named icon.png and logo.png (not .txt)

### Installation Issues
- [ ] Check Home Assistant logs
- [ ] Review add-on logs
- [ ] Verify configuration syntax
- [ ] Check system resources (disk space, memory)

### Runtime Issues
- [ ] Verify secrets are configured
- [ ] Check PostgreSQL is starting (look in logs)
- [ ] Verify port 1111 is not in use by another service
- [ ] Try stopping and restarting the add-on

## Success Criteria

You've successfully completed setup when:
- ✅ Add-on appears in Home Assistant add-on store
- ✅ Add-on installs without errors
- ✅ Add-on starts successfully
- ✅ Blinko interface accessible via ingress
- ✅ Can create and save notes
- ✅ Data persists across restarts
- ✅ Icons display correctly in add-on store

## Additional Resources

- **Home Assistant Add-on Documentation**: https://developers.home-assistant.io/docs/add-ons
- **Blinko GitHub**: https://github.com/blinkospace/blinko
- **Blinko Documentation**: https://docs.blinko.space
- **Home Assistant Community**: https://community.home-assistant.io

---

**Notes:**
- Take your time with each step
- Don't skip the testing phase
- Back up before making major changes
- Document any issues you encounter

Good luck with your Blinko Home Assistant add-on! 🚀
