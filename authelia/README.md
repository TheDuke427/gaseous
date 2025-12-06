# Authelia for Home Assistant

![Authelia Logo](https://www.authelia.com/images/branding/logo-cropped.png)

A complete self-hosted authentication solution for Home Assistant that integrates seamlessly with Cloudflare Zero Trust. Stop relying on third-party identity providers and take full control of your authentication stack.

## 🎯 What This Does

This add-on runs Authelia as an OpenID Connect (OIDC) provider that works with Cloudflare Zero Trust to protect your internet-facing services. Instead of using Google, GitHub, or other third-party auth providers, you authenticate users through your own self-hosted Authelia instance.

**Perfect for:**
- Protecting multiple subdomains with a single authentication layer
- Self-hosting enthusiasts who want complete data sovereignty
- Anyone running services through Cloudflare tunnels who needs enterprise-grade auth
- Teams that need centralized user management without paying for enterprise SSO

## ✨ Features

- **Self-Hosted Authentication**: Complete control over your identity provider
- **OIDC Integration**: Works seamlessly with Cloudflare Zero Trust
- **Multi-User Support**: Manage unlimited users directly from Home Assistant config
- **Persistent Secrets**: Secrets are generated once and persist across restarts
- **File-Based User Database**: No external database required - everything in SQLite
- **Easy Configuration**: Simple JSON config for users, domains, and settings
- **Production Ready**: Includes proper session management, rate limiting, and security

## 🚀 Quick Start

### Prerequisites

1. **Cloudflare Account** with Zero Trust enabled
2. **Custom Domain** pointed to Cloudflare
3. **Cloudflare Tunnel** set up to your Home Assistant instance
4. **Home Assistant** (obviously)

### Installation

1. Copy the `authelia` folder to your Home Assistant add-ons directory:
   ```
   /addons/authelia/
   ```

2. Refresh your add-on store and install "Authelia"

3. Configure the add-on with your settings:

```json
{
  "authelia_domain": "auth.yourdomain.com",
  "root_domain": "yourdomain.com",
  "cloudflare_team": "your-team-name",
  "users": [
    {
      "username": "admin",
      "password": "YourSecurePassword123!",
      "email": "admin@yourdomain.com",
      "displayname": "Administrator"
    }
  ]
}
```

4. **Start the add-on**

5. **Set up Cloudflare Tunnel** pointing `auth.yourdomain.com` to `http://YOUR_HA_IP:9091`

6. **Check the logs** for your Cloudflare OIDC configuration details

### Cloudflare Zero Trust Setup

1. Go to **Cloudflare Zero Trust → Settings → Authentication**
2. Click **Add new** → **OpenID Connect**
3. Fill in the details from your add-on logs:
   - **Name**: Authelia
   - **App ID**: `cloudflare`
   - **Client Secret**: (from logs)
   - **Auth URL**: `https://auth.yourdomain.com/api/oidc/authorization`
   - **Token URL**: `https://auth.yourdomain.com/api/oidc/token`
   - **Certificate URL**: `https://auth.yourdomain.com/jwks.json`
   - **Email claim**: `email`
4. **Test** and **Save**

### Protect Your Apps

1. Go to **Cloudflare Zero Trust → Access → Applications**
2. **Add an application** → Self-hosted
3. Set your subdomain (e.g., `app.yourdomain.com`)
4. Create a policy:
   - Action: **Allow**
   - Selector: **Login Methods**
   - Value: **Authelia** (your OIDC provider)
5. Save and deploy

Now anyone accessing `app.yourdomain.com` will be redirected to your self-hosted Authelia login!

## 📖 Configuration

### Required Settings

| Option | Description | Example |
|--------|-------------|---------|
| `authelia_domain` | Subdomain where Authelia is hosted | `auth.yourdomain.com` |
| `root_domain` | Your root domain | `yourdomain.com` |
| `cloudflare_team` | Your Cloudflare team name | Found in CF Zero Trust URL |
| `users` | Array of user objects | See below |

### User Configuration

Each user needs:
- `username` - Login username
- `password` - User's password (stored as Argon2 hash)
- `email` - User's email address
- `displayname` - Optional display name

### Optional Settings

| Option | Description | Default |
|--------|-------------|---------|
| `jwt_secret` | JWT signing secret | Auto-generated |
| `session_secret` | Session encryption secret | Auto-generated |
| `encryption_key` | Database encryption key | Auto-generated |

**Note**: Secrets are auto-generated on first run and persisted. Don't change them unless you know what you're doing!

## 🔐 Security Features

- **Argon2 Password Hashing**: Industry-standard password hashing
- **Rate Limiting**: Protection against brute force attacks (3 attempts per 2 minutes)
- **Session Management**: Secure session cookies with configurable timeouts
- **OIDC Standards**: Full compliance with OpenID Connect specifications
- **SQLite Encryption**: Local database with encryption at rest

## 🛠️ Advanced Usage

### Adding Multiple Users

Simply add more user objects to the `users` array:

```json
{
  "users": [
    {
      "username": "admin",
      "password": "SecurePass1!",
      "email": "admin@yourdomain.com",
      "displayname": "Admin User"
    },
    {
      "username": "john",
      "password": "JohnsPass2!",
      "email": "john@yourdomain.com",
      "displayname": "John Doe"
    },
    {
      "username": "jane",
      "password": "JanesPass3!",
      "email": "jane@yourdomain.com",
      "displayname": "Jane Smith"
    }
  ]
}
```

Restart the add-on and all users will be recreated from your config.

### Customizing Session Duration

Session settings are currently hardcoded but can be modified in `run.sh`:
- Session expiration: 1 hour
- Inactivity timeout: 5 minutes

### Log Levels

Change the log level in the generated config (requires modifying `run.sh`):
- `debug` - Verbose logging
- `info` - Normal operation (default)
- `warning` - Only warnings and errors
- `error` - Errors only

## 🐛 Troubleshooting

### "User email was not returned"

This means Cloudflare isn't getting the email claim. Check:
1. Certificate URL is set to `https://auth.yourdomain.com/jwks.json`
2. Email claim in Cloudflare is set to `email`
3. Your user database has valid email addresses

### "Failed to exchange code for token"

The client secret is wrong. Make sure:
1. You copied the EXACT secret from the add-on logs
2. You're using the secret from the LATEST restart (secrets persist now)
3. The secret in Cloudflare matches exactly (no extra spaces)

### "Redirect URI mismatch"

Your Cloudflare team name is wrong. Check:
1. Go to Cloudflare Zero Trust dashboard
2. Look at the URL - it contains your team name
3. Update `cloudflare_team` in your config
4. Restart the add-on

### Can't access Authelia web interface

Make sure:
1. Cloudflare tunnel is pointing to `http://YOUR_HA_IP:9091`
2. Port 9091 isn't blocked by firewall
3. The tunnel is active and running
4. DNS is properly configured

## 📝 Files Created

The add-on creates several files in `/data/`:

- `/data/authelia/configuration.yml` - Main Authelia config (regenerated on startup)
- `/data/authelia/db.sqlite3` - User sessions and OIDC data
- `/data/authelia/oidc_key.pem` - RSA private key for OIDC signing
- `/data/authelia/.jwt_secret` - Persistent JWT secret
- `/data/authelia/.session_secret` - Persistent session secret
- `/data/authelia/.encryption_key` - Persistent encryption key
- `/data/authelia/.cloudflare_secret` - Persistent Cloudflare client secret
- `/data/users/users_database.yml` - User database (regenerated from config)

## 🔄 Updating

To update user passwords or add/remove users:
1. Stop the add-on
2. Update your configuration
3. Start the add-on

The user database is regenerated from your config on every restart.

## ⚠️ Important Notes

- **Client Secret Persistence**: The Cloudflare client secret is generated once and persists. You only need to configure it in Cloudflare once.
- **User Database**: Users are regenerated from config on every restart. There's no way to edit users from Authelia's web interface.
- **No 2FA Yet**: This basic setup doesn't include TOTP/2FA. That can be added later if needed.
- **Single Domain**: Currently configured for one root domain. Multi-domain support requires manual config editing.

## 🎓 Learn More

- [Authelia Documentation](https://www.authelia.com/)
- [Cloudflare Zero Trust Docs](https://developers.cloudflare.com/cloudflare-one/)
- [OpenID Connect Specification](https://openid.net/connect/)

## 🤝 Contributing

Found a bug? Have a feature request? This add-on was built through a lot of trial and error. If you improve it, please share your changes!

## 📜 License

This add-on configuration is provided as-is. Authelia itself is licensed under Apache 2.0.

## 🙏 Credits

- **Authelia Team** - For building an amazing self-hosted auth solution
- **Home Assistant Community** - For the add-on framework
- **Cloudflare** - For Zero Trust (even though we're replacing their auth providers 😄)

---

**Ready to take control of your authentication?** Install this add-on and never worry about third-party identity providers again.

*Built with ☕ and lots of debugging*
