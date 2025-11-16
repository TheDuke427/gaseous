# 🚀 Deployment Checklist - Monica Home Assistant Add-on

## Pre-Deployment Checklist

### ✅ Repository Setup

- [ ] GitHub repository exists: `https://github.com/TheDuke427/gaseous`
- [ ] Repository is public (or users have access)
- [ ] Git is configured locally
- [ ] You have push access to the repository

### ✅ File Verification

- [ ] `monica/` folder is complete with all files
- [ ] `config.yaml` has correct settings
- [ ] `Dockerfile` has no syntax errors
- [ ] All scripts in `rootfs/` are present
- [ ] Documentation files are included
- [ ] `repository.json` is ready for root directory

### ✅ Script Permissions

Run this to ensure scripts are executable:
```bash
chmod +x monica/rootfs/etc/cont-init.d/10-monica.sh
chmod +x monica/rootfs/etc/services.d/nginx/run
chmod +x monica/rootfs/etc/services.d/php-fpm/run
```

---

## Deployment Steps

### 1. Add to Repository

```bash
# Navigate to your repository
cd /path/to/gaseous

# Copy monica folder
cp -r /path/to/monica ./

# Copy repository.json to root (if it doesn't exist)
cp monica/repository.json ./

# Verify structure
ls -la monica/
```

### 2. Commit Files

```bash
# Add files
git add monica/
git add repository.json  # if new

# Commit
git commit -m "Add Monica Personal CRM Home Assistant Add-on

- Full ingress support
- MariaDB integration
- Multi-architecture support
- Comprehensive documentation"

# Push to GitHub
git push origin main
```

### 3. Verify on GitHub

- [ ] Go to: `https://github.com/TheDuke427/gaseous`
- [ ] Confirm `monica/` folder is visible
- [ ] Click into folder and spot-check files
- [ ] Verify `repository.json` is in root

---

## First Test Installation

### 1. Add Repository to Home Assistant

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click menu (⋮) → **Repositories**
4. Add: `https://github.com/TheDuke427/gaseous`
5. Click **Add** and close

### 2. Install Add-on

1. Refresh add-on store
2. Find "Monica Personal CRM"
3. Click and read description
4. Click **Install**
5. Wait for installation (may take 5-10 minutes first time)

### 3. Configure Add-on

Set minimum configuration:
```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "test_password_123"
app_env: production
app_disable_signup: false
```

### 4. Prepare Database

```bash
# Connect to MariaDB
docker exec -it addon_core_mariadb mysql -u root -p

# Run these commands:
CREATE DATABASE monica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'monica'@'%' IDENTIFIED BY 'test_password_123';
GRANT ALL PRIVILEGES ON monica.* TO 'monica'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### 5. Start Add-on

1. Click **Start**
2. Watch logs for errors
3. Wait for "Monica configuration completed!" message

### 6. Test Access

- [ ] Click "Open Web UI" or check sidebar
- [ ] Monica interface loads correctly
- [ ] Create a test account
- [ ] Add a test contact
- [ ] Verify data saves
- [ ] Test restart (data should persist)

---

## Testing Checklist

### ⚙️ Functionality Tests

- [ ] **Database Connection**
  - Add-on starts without errors
  - Database initializes correctly
  - Migrations run successfully

- [ ] **Web Interface**
  - Ingress access works
  - Direct port access works (if enabled)
  - Pages load correctly
  - No JavaScript errors in console

- [ ] **User Management**
  - Can create first account
  - Can log in/out
  - Password reset works (with email)
  - Signup disable works

- [ ] **Core Features**
  - Can add/edit contacts
  - Can add relationships
  - Can set reminders
  - Can add notes
  - Can upload files
  - Can use journal

- [ ] **Persistence**
  - Data survives restart
  - Data survives add-on update
  - APP_KEY persists
  - Configuration persists

### 🔒 Security Tests

- [ ] APP_KEY generates correctly
- [ ] Passwords are hashed
- [ ] HTTPS works via ingress
- [ ] Direct HTTP access (if exposed)
- [ ] Signup restriction works
- [ ] SQL injection prevention
- [ ] XSS prevention
- [ ] File upload restrictions

### 📧 Email Tests (Optional)

- [ ] SMTP connection works
- [ ] Test email sends
- [ ] Reminders send
- [ ] Password reset emails

### 📊 Performance Tests

- [ ] Reasonable load times
- [ ] Memory usage acceptable
- [ ] No memory leaks
- [ ] Database queries optimized

---

## Troubleshooting Common Issues

### Issue: Add-on won't start

**Check:**
1. MariaDB is running
2. Database credentials are correct
3. Database exists
4. User has permissions
5. Check logs for specific errors

**Fix:**
```bash
# View logs
docker logs addon_XXXXXXXX_monica -f

# Check MariaDB
docker exec -it addon_core_mariadb mysql -u monica -p
```

### Issue: Can't access web interface

**Check:**
1. Add-on is running
2. Ingress is enabled
3. Port is correct (if using direct)
4. No proxy conflicts

**Fix:**
- Try direct port access first
- Check nginx logs
- Verify Home Assistant ingress settings

### Issue: Database connection fails

**Check:**
1. MariaDB add-on running
2. Hostname correct (usually `core-mariadb`)
3. Port correct (usually `3306`)
4. Credentials match database

**Fix:**
```bash
# Test connection
mysql -h core-mariadb -u monica -p
```

### Issue: Ingress not working

**Check:**
1. `ingress: true` in config.yaml
2. Home Assistant version supports ingress
3. No ingress token errors in HA logs

**Fix:**
- Use direct port temporarily
- Check HA supervisor logs
- Restart Home Assistant

---

## Post-Deployment

### 1. Documentation

- [ ] Update your repository README
- [ ] Add screenshots (optional)
- [ ] Create usage examples
- [ ] Document any quirks

### 2. Community

- [ ] Post on Home Assistant forums
- [ ] Share on Reddit r/homeassistant
- [ ] Create GitHub discussions
- [ ] Respond to issues

### 3. Maintenance

- [ ] Set up GitHub notifications
- [ ] Monitor for Monica updates
- [ ] Plan update schedule
- [ ] Keep documentation current

### 4. Optional Enhancements

- [ ] Set up GitHub Actions for auto-builds
- [ ] Add automated testing
- [ ] Create demo video
- [ ] Add more examples
- [ ] Create integration guides

---

## GitHub Actions Setup (Optional)

If you want automatic Docker image builds:

1. Create `.github/workflows/builder.yml` (see INSTALL.md)
2. Add required secrets to GitHub repository
3. Push and watch Actions tab
4. Images will build automatically

---

## Success Criteria

Your deployment is successful when:

✅ Add-on installs from repository
✅ Configuration is straightforward
✅ Database initializes automatically
✅ Web interface is accessible
✅ Core features work correctly
✅ Data persists across restarts
✅ Documentation is clear
✅ No critical errors in logs

---

## Support Plan

Be ready to:

1. **Monitor GitHub Issues**
   - Respond within 24-48 hours
   - Reproduce reported bugs
   - Provide workarounds

2. **Update Documentation**
   - Fix unclear sections
   - Add FAQ entries
   - Include troubleshooting tips

3. **Release Updates**
   - Follow semantic versioning
   - Update CHANGELOG.md
   - Test before releasing

4. **Engage Community**
   - Thank contributors
   - Review pull requests
   - Share updates

---

## Version History Template

When you release updates, use this format in CHANGELOG.md:

```markdown
## [4.1.3] - YYYY-MM-DD

### Added
- New feature X
- Support for Y

### Changed
- Improved Z
- Updated documentation

### Fixed
- Bug in feature A
- Issue with B

### Security
- Updated dependency C
- Fixed vulnerability D
```

---

## Backup Before Major Changes

Always backup before:

1. Changing Dockerfile base image
2. Updating Monica version
3. Modifying database schema
4. Changing configuration structure

```bash
# Backup command for users
mysqldump -u monica -p monica > monica_backup_$(date +%Y%m%d).sql
```

---

## 🎉 You're Ready!

If you've checked everything above, you're ready to deploy!

**Final Steps:**
1. ✅ Copy monica folder to repository
2. ✅ Commit and push
3. ✅ Test installation
4. ✅ Share with community

**Questions?** Check the documentation:
- `00-START-HERE.md` - Overview
- `INSTALL.md` - Setup details
- `DOCS.md` - Technical info

**Good luck with your deployment!** 🚀
