# Monica Personal CRM - Quick Start Guide

## Prerequisites

✅ Home Assistant installed and running
✅ MariaDB add-on installed and configured
✅ Basic understanding of Home Assistant add-ons

## Installation Steps

### 1. Install MariaDB Add-on (if not already installed)

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Search for "MariaDB"
3. Install and start the MariaDB add-on
4. Note your root password

### 2. Create Monica Database

Connect to MariaDB and create the database:

```sql
CREATE DATABASE monica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'monica'@'%' IDENTIFIED BY 'YourSecurePassword123!';
GRANT ALL PRIVILEGES ON monica.* TO 'monica'@'%';
FLUSH PRIVILEGES;
```

**Using MariaDB Web Terminal:**
1. Open MariaDB add-on
2. Go to "Configuration" tab
3. Add your commands to execute on startup, OR
4. Use the web interface if available

**Using Home Assistant CLI:**
```bash
docker exec -it addon_core_mariadb mysql -u root -p
```

### 3. Add Monica Add-on Repository

1. Go to **Settings** → **Add-ons** → **Add-on Store**
2. Click the three dots (⋮) in the top right
3. Select "Repositories"
4. Add: `https://github.com/TheDuke427/gaseous`
5. Click "Add"

### 4. Install Monica Add-on

1. Refresh the add-on store
2. Find "Monica Personal CRM"
3. Click to open
4. Click "Install"
5. Wait for installation to complete

### 5. Configure Monica

Click on the "Configuration" tab and set:

**Minimum Configuration:**
```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "YourSecurePassword123!"
app_env: production
app_disable_signup: false
```

**With Email (Optional):**
```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "YourSecurePassword123!"
app_env: production
app_disable_signup: false
mail_mailer: smtp
mail_host: smtp.gmail.com
mail_port: 587
mail_username: your-email@gmail.com
mail_password: your-app-password
mail_encryption: tls
mail_from_address: your-email@gmail.com
mail_from_name: Monica
```

### 6. Start Monica

1. Go to the "Info" tab
2. Toggle "Start on boot" (recommended)
3. Click "Start"
4. Wait for startup (check logs if needed)

### 7. Access Monica

**Via Sidebar (Ingress):**
1. Look for "Monica Personal CRM" in your Home Assistant sidebar
2. Click to open

**Via Direct Access:**
1. Find the port in add-on info
2. Go to `http://homeassistant.local:PORT`

### 8. Create Your Account

1. Click "Register" or "Sign up"
2. Enter your email and password
3. Complete registration

### 9. Disable Signups (Security)

After creating your account:
1. Go to add-on Configuration
2. Change `app_disable_signup: true`
3. Save and restart the add-on

## Initial Setup in Monica

### Add Your First Contact

1. Click "Add a contact" or "+"
2. Fill in basic information
3. Click "Save"

### Set Up Reminders

1. Open a contact
2. Go to "Reminders" section
3. Click "Add a reminder"
4. Choose frequency and date
5. Save

### Import Contacts (Optional)

1. Go to Settings → Import
2. Choose your import source
3. Follow the import wizard

## Tips for Best Results

### 1. Regular Updates
- Add contacts as you meet new people
- Log interactions after important conversations
- Set reminders for follow-ups

### 2. Use Tags
- Organize contacts with labels
- Examples: "Work", "Family", "Close Friends"
- Easy filtering later

### 3. Birthday Reminders
- Add birthdays when creating contacts
- Monica will automatically remind you

### 4. Journal Entries
- Use the journal feature regularly
- Tag relevant contacts
- Great for personal reflection

### 5. Mobile Access
- Access via Home Assistant mobile app
- Add to home screen for quick access
- Consider Monica's official mobile app for CardDAV sync

## Common First-Time Issues

### Can't Access Monica
- ✅ Check add-on is running
- ✅ Verify ingress is enabled
- ✅ Try direct port access
- ✅ Check Home Assistant logs

### Database Connection Error
- ✅ Verify MariaDB is running
- ✅ Double-check password
- ✅ Ensure database was created
- ✅ Check user permissions

### Can't Create Account
- ✅ Verify `app_disable_signup` is `false`
- ✅ Check logs for errors
- ✅ Restart add-on
- ✅ Clear browser cache

### Email Not Working
- ✅ Test with `mail_mailer: log` first
- ✅ Check SMTP credentials
- ✅ Verify port isn't blocked
- ✅ Use app-specific password for Gmail

## Next Steps

Once you're set up:

1. **Explore Features**
   - Activities
   - Debts and gifts
   - Document uploads
   - Custom fields

2. **Customize Settings**
   - Go to Settings in Monica
   - Adjust preferences
   - Configure reminders

3. **Set Up Backups**
   - Include in Home Assistant backups
   - Or backup MariaDB separately
   - Test restore process

4. **Mobile Sync (Advanced)**
   - Enable CardDAV in settings
   - Configure on mobile device
   - Sync contacts automatically

## Getting Help

### Check Logs
```
Settings → Add-ons → Monica Personal CRM → Log
```

### Documentation
- [Full README](README.md)
- [Developer Docs](DOCS.md)
- [Monica Official Docs](https://docs.monicahq.com/)

### Community Support
- [Home Assistant Community](https://community.home-assistant.io/)
- [Monica GitHub Discussions](https://github.com/monicahq/monica/discussions)
- [Add-on GitHub Issues](https://github.com/TheDuke427/gaseous/issues)

## Maintenance

### Regular Tasks
- ☐ Weekly: Review and update contacts
- ☐ Monthly: Check for updates
- ☐ Monthly: Verify backups
- ☐ Quarterly: Database optimization
- ☐ Yearly: Review and clean old data

### Updates
Home Assistant will notify you of add-on updates. Always:
1. Backup before updating
2. Read changelog
3. Update during low-usage time

---

**Enjoy using Monica!** 🎉

Remember: Monica is designed to help you build and maintain meaningful relationships. The more you use it, the more valuable it becomes!
