# Monica CRM - Home Assistant Add-on

![Monica CRM](https://raw.githubusercontent.com/monicahq/monica/main/docs/images/logo.png)

A self-hosted personal relationship management system for Home Assistant. Monica helps you organize and remember details about your friends, family, and colleagues.

---

## ✨ Features

- 📇 **Contact Management** - Store detailed information about people in your life
- 📅 **Important Dates** - Track birthdays, anniversaries, and special occasions
- 📝 **Notes & Activities** - Keep a timeline of interactions and memories
- 📎 **Document Storage** - Upload and manage photos and files
- 🔐 **Self-Hosted** - Your data stays on your server
- 🌐 **Cloudflare Tunnel Support** - Secure external access via HTTPS
- 💾 **Persistent Storage** - Files and data survive container restarts

---

## 🚀 Installation

### Prerequisites

- Home Assistant OS or Supervised
- MariaDB add-on (recommended) or external MySQL database
- At least 2GB free storage space

### Steps

1. **Add the Repository**
   - Go to **Supervisor** → **Add-on Store** → **⋮** (three dots) → **Repositories**
   - Add this repository URL: `[YOUR_REPO_URL]`

2. **Install the Add-on**
   - Find "Monica CRM" in the add-on store
   - Click **Install**
   - Wait for the installation to complete (this may take 5-10 minutes due to dependency compilation)

3. **Configure the Add-on**
   - Go to the **Configuration** tab
   - Set your database credentials
   - (Optional) Set your custom domain in `app_url` if using Cloudflare Tunnel

4. **Start the Add-on**
   - Click **Start**
   - Check the **Log** tab for any errors
   - Wait for "Monica ready" message

5. **Access Monica**
   - Local access: `http://YOUR_HOME_ASSISTANT_IP:8181`
   - Or via your configured custom domain

---

## ⚙️ Configuration

### Basic Configuration

```yaml
db_host: core-mariadb
db_port: 3306
db_database: monica
db_user: monica
db_password: changeme
app_url: http://localhost:8181
```

### Configuration Options

| Option | Required | Default | Description |
|--------|----------|---------|-------------|
| `db_host` | Yes | `core-mariadb` | Database hostname |
| `db_port` | Yes | `3306` | Database port |
| `db_database` | Yes | `monica` | Database name |
| `db_user` | Yes | `monica` | Database username |
| `db_password` | Yes | `changeme` | Database password |
| `app_url` | Yes | `http://localhost:8181` | Full URL where Monica will be accessed (include `https://` if using Cloudflare Tunnel) |

### Database Setup

If using the **MariaDB add-on**:

1. Install the MariaDB add-on from the official add-on store
2. Create a database for Monica:
   ```sql
   CREATE DATABASE monica;
   CREATE USER 'monica'@'%' IDENTIFIED BY 'your_secure_password';
   GRANT ALL PRIVILEGES ON monica.* TO 'monica'@'%';
   FLUSH PRIVILEGES;
   ```
3. Use `core-mariadb` as the `db_host` in Monica configuration

### External Access via Cloudflare Tunnel

For secure HTTPS access from outside your network:

1. Set up a Cloudflare Tunnel pointing to `http://YOUR_HA_IP:8181`
2. In Monica configuration, set `app_url` to your full domain:
   ```yaml
   app_url: https://your-subdomain.yourdomain.com
   ```
3. Restart the add-on
4. Access Monica at your custom domain

---

## 📱 First-Time Setup

1. **Create Your Account**
   - Navigate to Monica in your browser
   - Click "Register" 
   - Fill in your name, email, and password
   - Your account will be automatically verified (no email confirmation needed)

2. **Start Adding Contacts**
   - Click "Contacts" → "Add a contact"
   - Fill in their information
   - Upload photos and documents as needed

3. **Explore Features**
   - Set up important dates (birthdays, anniversaries)
   - Log activities and interactions
   - Create notes and reminders
   - Organize contacts with labels and groups

---

## 📁 File Uploads

Monica supports uploading photos and documents for your contacts.

**Supported Features:**
- Avatar photos for contacts
- Document attachments
- Photo galleries
- 5GB default storage limit per account

**Note:** File uploads use Uploadcare integration. The add-on is pre-configured with demo keys for basic functionality.

---

## 🔧 Troubleshooting

### Cannot Login After Setup

**Symptom:** Login button clears password field but doesn't log you in.

**Solution:** 
- Clear your browser cache and cookies for the Monica domain
- Try accessing in an incognito/private window
- Check that `app_url` matches how you're accessing Monica (HTTP vs HTTPS)

### 419 Page Expired Error

**Symptom:** Getting "419 Page Expired" errors, especially on mobile.

**Solution:**
- This is a CSRF token issue
- Clear browser cookies completely
- Ensure cookies are enabled in your browser
- Try disabling "Prevent Cross-Site Tracking" on iOS Safari

### 502 Bad Gateway on Page Refresh

**Symptom:** Pages load initially but refreshing causes 502 errors.

**Solution:**
- This is a known limitation of PHP's built-in server
- Wait 30 seconds and try again
- Consider the page successfully loaded on first try

### Mixed Content Errors (HTTPS)

**Symptom:** Page loads but assets/login doesn't work when accessing via HTTPS.

**Solution:**
- Ensure `app_url` in configuration uses `https://` not `http://`
- Restart the add-on after changing `app_url`
- Clear browser cache

### No File Upload Options

**Symptom:** Cannot see buttons to upload photos or documents.

**Solution:**
- Check that the add-on has access to `/share` storage
- Verify the configuration includes the demo Uploadcare keys
- Check the logs for any storage-related errors

---

## 🗄️ Data & Backups

### Data Locations

- **Database:** Stored in your MariaDB instance
- **Uploaded Files:** `/share/monica/storage/` on your Home Assistant server
- **Application Key:** `/data/app_key` (persistent across restarts)

### Backup Recommendations

1. **Database Backup**
   - Use MariaDB add-on's backup features, or
   - Manual backup: `mysqldump -u monica -p monica > monica_backup.sql`

2. **File Storage Backup**
   - Back up the `/share/monica/` directory
   - Use Home Assistant's backup features

3. **Regular Backups**
   - Schedule regular Home Assistant backups that include add-on data
   - Store backups off-site for disaster recovery

---

## 🔄 Updating

When a new version of the add-on is available:

1. Go to **Supervisor** → **Dashboard**
2. Click on **Monica CRM**
3. Click **Update** if available
4. Wait for the update to complete
5. Restart the add-on

**Note:** Major updates may require database migrations which can take several minutes.

---

## 🐛 Known Issues

- **502 errors on refresh:** Occasional gateway timeouts when refreshing pages rapidly. Wait a few seconds and try again.
- **Mobile session timeouts:** Some mobile browsers may expire sessions more aggressively. Simply log back in.
- **File upload size limits:** Default limit is 100MB per file. This is a PHP limitation.

---

## 📚 Additional Resources

- [Monica Official Documentation](https://docs.monicahq.com/)
- [Monica GitHub Repository](https://github.com/monicahq/monica)
- [Home Assistant Community](https://community.home-assistant.io/)

---

## 🤝 Contributing

Found a bug or have a feature request? Please open an issue on the GitHub repository.

---

## 📜 License

This add-on is provided as-is under the MIT License.

Monica CRM itself is licensed under AGPL-3.0 - see the [Monica repository](https://github.com/monicahq/monica) for details.

---

## ❤️ Credits

- **Monica CRM** - Created by [Régis Freyd](https://github.com/djaiss) and the Monica team
- **Add-on Development** - Community contribution for Home Assistant

---

## 🎉 Enjoy!

You now have a powerful personal CRM running right on your Home Assistant server. Start building better relationships by staying organized and thoughtful with Monica!

**Happy relationship managing! 📇💙**
