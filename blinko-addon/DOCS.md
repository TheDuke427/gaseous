# Configuration

This add-on requires minimal configuration but **must have secure passwords set** before use.

## Options

### Option: `postgres_password`

The password for the PostgreSQL database. This should be a strong, unique password.

**Required**: Yes  
**Default**: `changeme_postgres_password`

```yaml
postgres_password: "MyS3cur3P0stgr3sP@ssw0rd!"
```

⚠️ **Important**: Change this from the default value before starting the add-on!

### Option: `nextauth_secret`

The secret key used by NextAuth for JWT token encryption and session management. This must be at least 32 characters long.

**Required**: Yes  
**Default**: `changeme_nextauth_secret_min_32_chars`

```yaml
nextauth_secret: "a_very_long_random_secret_key_with_at_least_32_characters_12345"
```

⚠️ **Important**: 
- Change this from the default value before starting the add-on!
- Use a cryptographically random string
- Keep this secret safe - anyone with this key could forge authentication tokens

You can generate a secure secret using:
```bash
openssl rand -base64 32
```

### Option: `timezone`

The timezone for the application. This affects timestamps in your notes and database entries.

**Required**: Yes  
**Default**: `America/New_York`

```yaml
timezone: "Europe/London"
```

Common timezone values:
- `America/New_York`
- `America/Los_Angeles`
- `Europe/London`
- `Europe/Paris`
- `Asia/Tokyo`
- `Australia/Sydney`

See the [full list of timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones) for more options.

## Example Complete Configuration

```yaml
postgres_password: "SuperSecurePassword123!@#"
nextauth_secret: "this_is_a_very_long_and_secure_random_string_for_nextauth_jwt_tokens_98765"
timezone: "America/Chicago"
```

## Ingress Configuration

This add-on supports Home Assistant Ingress by default. Ingress allows you to access Blinko through your Home Assistant interface without exposing additional ports.

When Ingress is enabled (default):
- Access Blinko through the Home Assistant sidebar
- No need to remember port numbers
- Authentication is handled by Home Assistant
- More secure as no external ports are exposed

## Port Configuration

By default, port 1111 is not exposed externally when using Ingress. If you need direct access:

1. Go to the add-on's "Configuration" tab
2. Enable "Show in sidebar" for easy access via Ingress
3. Or manually expose port 1111 in your network configuration (advanced users only)

## Data Storage

All data is automatically stored in:
- `/data/postgres` - PostgreSQL database files
- `/data/blinko` - Blinko application data and attachments

These directories are persistent and survive add-on restarts and updates.

## Backup Recommendations

To backup your Blinko data:

1. **Automatic**: Home Assistant backups include all add-on data
2. **Manual**: 
   - Copy `/data/postgres` for database backup
   - Copy `/data/blinko` for application data backup

Restore by copying these directories back to the same locations.

## Troubleshooting

### Add-on won't start

1. Check you've changed both default passwords
2. Verify `nextauth_secret` is at least 32 characters
3. Check add-on logs for specific errors

### Can't access Blinko

1. Verify the add-on is running (green status)
2. Check "Show in sidebar" is enabled
3. Try accessing via Ingress first before using direct port access

### Database connection errors

1. Wait 30 seconds after starting for PostgreSQL to initialize
2. Check logs for PostgreSQL initialization errors
3. Verify disk space is available in `/data`

### Performance issues

1. Blinko requires Docker-in-Docker, which needs adequate resources
2. Ensure your Home Assistant host has sufficient RAM (4GB+ recommended)
3. Check CPU usage in the add-on info

## Security Considerations

1. **Always change default passwords** - Both `postgres_password` and `nextauth_secret` must be changed
2. **Use strong passwords** - Minimum 16 characters with mixed case, numbers, and symbols
3. **Keep secrets secret** - Don't share your configuration containing passwords
4. **Use Ingress** - More secure than exposing ports directly
5. **Regular backups** - Include add-on data in your Home Assistant backup routine

## Advanced Configuration

### AI Features

Blinko includes AI-powered search features. To use external AI services:

1. Configure AI settings within the Blinko web interface
2. Enter API keys for your preferred AI provider (OpenAI, etc.)
3. AI features are optional and can be disabled

### Mobile Access

Access Blinko from mobile devices:

1. Use the Home Assistant mobile app
2. Navigate to Blinko in the sidebar
3. Add to home screen for quick access

### Markdown Support

Blinko fully supports Markdown formatting:
- Headers: `# H1`, `## H2`, etc.
- Lists: `- item` or `1. item`
- Links: `[text](url)`
- Images: `![alt](url)`
- Code blocks: ``` ```code``` ```
- Tags: `#tag-name`

## Support

If you encounter issues:

1. Check the add-on logs in Home Assistant
2. Search the [Blinko GitHub Issues](https://github.com/blinkospace/blinko/issues)
3. Visit the Home Assistant Community Forum
4. Provide logs and configuration (remove passwords!) when asking for help
