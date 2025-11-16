# Monica Personal CRM - Home Assistant Add-on

![Monica Logo](https://raw.githubusercontent.com/monicahq/monica/main/docs/images/logo.png)

Monica is an open-source web application to organize and log your interactions with your loved ones. Think of it as a Personal Relationship Management (PRM) tool - a CRM for your friends, family, and acquaintances.

## About

Monica lets you:
- Add and manage contacts
- Define relationships between contacts
- Set reminders for important dates
- Automatic birthday reminders
- Record notes about your contacts
- Track how you met someone
- Log activities and conversations
- Manage tasks related to contacts
- Store addresses and contact information
- Upload documents and photos
- Keep a personal journal/diary
- Organize contacts with labels
- Support for multiple vaults and users

## Installation

1. Add this repository to your Home Assistant add-on store
2. Install the "Monica Personal CRM" add-on
3. Configure your MariaDB settings
4. Start the add-on
5. Access Monica through the Home Assistant sidebar

## Configuration

### MariaDB Database Setup

Before starting the add-on, ensure your MariaDB add-on is installed and running. You'll need to create a database and user for Monica.

**Option 1: Using the MariaDB web interface (if available)**
1. Access your MariaDB interface
2. Create a new database called `monica`
3. Create a user `monica` with a strong password
4. Grant all privileges on the `monica` database to the `monica` user

**Option 2: Using the MariaDB CLI**
```bash
# Connect to MariaDB
mysql -u root -p

# Create database and user
CREATE DATABASE monica CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'monica'@'%' IDENTIFIED BY 'your_secure_password';
GRANT ALL PRIVILEGES ON monica.* TO 'monica'@'%';
FLUSH PRIVILEGES;
EXIT;
```

### Add-on Configuration

```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "your_secure_password"
app_env: production
app_disable_signup: true
mail_mailer: log
mail_host: ""
mail_port: 587
mail_username: ""
mail_password: ""
mail_encryption: tls
mail_from_address: ""
mail_from_name: Monica
```

### Configuration Options

#### Database Settings

| Option | Type | Required | Description |
|--------|------|----------|-------------|
| `db_host` | string | Yes | Hostname of your MariaDB server (usually `core-mariadb`) |
| `db_port` | int | Yes | Port for MariaDB (default: `3306`) |
| `db_name` | string | Yes | Name of the database (recommended: `monica`) |
| `db_user` | string | Yes | Database username |
| `db_password` | string | Yes | Database password |

#### Application Settings

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `app_env` | list | production | Application environment (`local` or `production`). Use `production` for normal use |
| `app_disable_signup` | bool | true | Disable new user registration after initial setup |

#### Mail Settings (Optional)

If you want Monica to send email reminders and notifications:

| Option | Type | Description |
|--------|------|-------------|
| `mail_mailer` | list | Mail driver (`log`, `smtp`, or `sendmail`) |
| `mail_host` | string | SMTP server hostname |
| `mail_port` | int | SMTP port (usually 587 for TLS) |
| `mail_username` | string | SMTP username |
| `mail_password` | string | SMTP password |
| `mail_encryption` | list | Encryption method (`tls`, `ssl`, or `null`) |
| `mail_from_address` | email | Email address to send from |
| `mail_from_name` | string | Display name for outgoing emails |

#### Example SMTP Configurations

**Gmail:**
```yaml
mail_mailer: smtp
mail_host: smtp.gmail.com
mail_port: 587
mail_username: your-email@gmail.com
mail_password: your-app-password
mail_encryption: tls
mail_from_address: your-email@gmail.com
mail_from_name: Monica
```

**SendGrid:**
```yaml
mail_mailer: smtp
mail_host: smtp.sendgrid.net
mail_port: 587
mail_username: apikey
mail_password: your-sendgrid-api-key
mail_encryption: tls
mail_from_address: your-verified-email@example.com
mail_from_name: Monica
```

## First Use

1. After starting the add-on, click "Open Web UI" or access it from the sidebar
2. Create your first user account
3. Once registered, it's recommended to set `app_disable_signup: true` in the configuration to prevent others from creating accounts

## Features

### Contact Management
- Store detailed information about people in your life
- Track birthdays and important dates
- Add custom fields specific to your needs
- Upload photos and documents

### Relationships
- Define how contacts know each other
- Track family trees
- Document relationship history

### Activities & Conversations
- Log conversations and interactions
- Track when you last contacted someone
- Record activities you did together

### Reminders
- Set custom reminders for any contact
- Automatic birthday reminders
- Get email notifications (if SMTP configured)

### Journal
- Keep a personal diary
- Tag entries with contacts
- Search through your history

### Privacy
- All data stored locally on your Home Assistant instance
- No data sent to external servers
- Full control over your information

## Backup & Restore

Your Monica data is stored in your MariaDB database. To backup Monica:

1. **Backup the database:**
   - Use your MariaDB backup solution
   - Or export the `monica` database using mysqldump:
   ```bash
   mysqldump -u monica -p monica > monica_backup.sql
   ```

2. **Backup the add-on configuration:**
   - Your configuration is stored in Home Assistant's add-on config
   - Include it in your Home Assistant backups

To restore:
1. Restore your MariaDB database
2. Reinstall the add-on with the same configuration
3. Monica will automatically detect and use the existing database

## Troubleshooting

### Add-on won't start

1. **Check MariaDB is running:**
   - Ensure the MariaDB add-on is started
   - Verify you can connect to MariaDB

2. **Verify database credentials:**
   - Check the username and password are correct
   - Ensure the database exists
   - Verify the user has proper permissions

3. **Check the logs:**
   - Go to the add-on page
   - Click on the "Log" tab
   - Look for specific error messages

### Cannot create first user

1. Make sure `app_disable_signup` is set to `false`
2. Restart the add-on
3. Try accessing the web interface again

### Ingress not working

1. Verify ingress is enabled in the add-on configuration
2. Try accessing via direct port if ingress fails
3. Check Home Assistant logs for ingress-related errors

### Email reminders not working

1. Verify your SMTP settings are correct
2. Test with `mail_mailer: log` first (emails will appear in logs)
3. Check if your email provider requires app-specific passwords
4. Ensure your SMTP port is not blocked by your network

### Database connection errors

1. Verify MariaDB is running: `docker ps | grep mariadb`
2. Test database connection:
   ```bash
   mysql -h core-mariadb -u monica -p
   ```
3. Check if the database exists:
   ```sql
   SHOW DATABASES;
   ```

## Updating

Updates to the add-on can be installed through the Home Assistant add-on store. Your data will be preserved during updates.

**Before updating:**
1. Always backup your database
2. Read the changelog for breaking changes
3. Test in a non-production environment if possible

## Performance Tips

1. **Database maintenance:**
   - Periodically optimize your MariaDB database
   - Monitor database size and performance

2. **Media files:**
   - Monica stores uploaded files in the database
   - Consider limiting file uploads to reasonable sizes
   - Regularly review and remove unnecessary attachments

3. **Resource allocation:**
   - Monica runs well on modest hardware
   - Allocate sufficient memory to MariaDB for best performance

## Support

For issues specific to this Home Assistant add-on:
- Create an issue on the [GitHub repository](https://github.com/TheDuke427/gaseous)

For Monica application issues:
- Check the [Monica documentation](https://docs.monicahq.com/)
- Visit the [Monica GitHub repository](https://github.com/monicahq/monica)
- Join the [Monica community](https://github.com/monicahq/monica/discussions)

## Credits

- **Monica CRM:** Created by Régis Freyd and the Monica community
- **Home Assistant Add-on:** Created by TheDuke427
- **License:** AGPL-3.0 (Monica CRM)

## Changelog

See the [CHANGELOG.md](CHANGELOG.md) file for version history.

## Disclaimer

This is an unofficial Home Assistant add-on for Monica. It is not affiliated with or endorsed by the Monica project.
