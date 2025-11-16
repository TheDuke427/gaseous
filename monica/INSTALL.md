# Monica Home Assistant Add-on Installation Guide

## For Repository Setup

### Step 1: Add Files to Your Repository

Copy the entire `monica` folder to your repository at:
```
https://github.com/TheDuke427/gaseous/
```

The structure should be:
```
gaseous/
├── monica/
│   ├── config.yaml
│   ├── build.yaml
│   ├── Dockerfile
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── DOCS.md
│   ├── QUICKSTART.md
│   ├── icon.json
│   ├── logo.svg
│   ├── .gitignore
│   └── rootfs/
│       └── etc/
│           ├── cont-init.d/
│           │   └── 10-monica.sh
│           ├── services.d/
│           │   ├── nginx/
│           │   │   └── run
│           │   └── php-fpm/
│           │       └── run
│           └── nginx/
│               ├── nginx.conf
│               └── templates/
│                   └── monica.conf.template
└── (other add-ons...)
```

### Step 2: Create repository.json (if not exists)

In the root of your repository, create or update `repository.json`:

```json
{
  "name": "TheDuke427's Home Assistant Add-ons",
  "url": "https://github.com/TheDuke427/gaseous",
  "maintainer": "TheDuke427"
}
```

### Step 3: Commit and Push

```bash
git add monica/
git commit -m "Add Monica Personal CRM add-on"
git push origin main
```

### Step 4: Build Images (Optional - GitHub Actions)

If you want automatic builds, create `.github/workflows/builder.yml`:

```yaml
name: Builder

on:
  push:
    branches:
      - main
  pull_request:
    branches:
      - main

jobs:
  build:
    runs-on: ubuntu-latest
    name: Build ${{ matrix.arch }} ${{ matrix.addon }}
    strategy:
      matrix:
        addon:
          - monica
        arch:
          - aarch64
          - amd64
          - armhf
          - armv7
          - i386

    steps:
      - name: Check out repository
        uses: actions/checkout@v3

      - name: Get information
        id: info
        uses: home-assistant/actions/helpers/info@master
        with:
          path: "./${{ matrix.addon }}"

      - name: Check if add-on should be built
        id: check
        run: |
          if [[ "${{ steps.info.outputs.architectures }}" =~ ${{ matrix.arch }} ]]; then
            echo "build_arch=true" >> $GITHUB_OUTPUT
          else
            echo "build_arch=false" >> $GITHUB_OUTPUT
          fi

      - name: Login to GitHub Container Registry
        if: steps.check.outputs.build_arch == 'true'
        uses: docker/login-action@v2
        with:
          registry: ghcr.io
          username: ${{ github.repository_owner }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build ${{ matrix.addon }} add-on
        if: steps.check.outputs.build_arch == 'true'
        uses: home-assistant/builder@master
        with:
          args: |
            --${{ matrix.arch }} \
            --target /data/${{ matrix.addon }} \
            --image "${{ steps.info.outputs.slug }}-{arch}" \
            --docker-hub "ghcr.io/${{ github.repository_owner }}" \
            --addon
```

## For Users

### Adding the Repository to Home Assistant

1. Open Home Assistant
2. Go to **Settings** → **Add-ons** → **Add-on Store**
3. Click the menu (⋮) in the top right
4. Select **Repositories**
5. Add this URL:
   ```
   https://github.com/TheDuke427/gaseous
   ```
6. Click **Add**
7. Close the dialog

### Installing Monica

1. Refresh the add-on store page
2. Scroll down to find "Monica Personal CRM"
3. Click on it
4. Click **Install**
5. Wait for installation to complete
6. Configure (see below)
7. Start the add-on

### Configuration

See [QUICKSTART.md](QUICKSTART.md) for complete setup instructions.

Minimum configuration:
```yaml
db_host: core-mariadb
db_port: 3306
db_name: monica
db_user: monica
db_password: "your_secure_password"
app_env: production
app_disable_signup: false
```

## Updating the Add-on

### For Maintainers

1. Make changes to the add-on files
2. Update version in `config.yaml`
3. Update `CHANGELOG.md`
4. Commit and push
5. GitHub Actions will build automatically (if configured)

### For Users

1. Go to **Settings** → **Add-ons**
2. Find Monica Personal CRM
3. If an update is available, click **Update**
4. Wait for update to complete
5. Restart if needed

## Troubleshooting Build Issues

### Docker Build Locally

To test building locally:

```bash
docker build -t monica-test ./monica/
```

### Architecture-Specific Builds

To build for a specific architecture:

```bash
# For ARM64 (Raspberry Pi 4, etc.)
docker buildx build --platform linux/arm64 -t monica-arm64 ./monica/

# For AMD64 (most PCs)
docker buildx build --platform linux/amd64 -t monica-amd64 ./monica/
```

### Common Build Errors

1. **Base image not found**
   - Check `build.yaml` for correct base image versions
   - Verify internet connection

2. **Git clone fails**
   - Check Monica repository is accessible
   - Verify branch name is correct

3. **Composer install fails**
   - May need to increase Docker memory
   - Check for PHP version compatibility

4. **Permission errors**
   - Ensure all scripts are executable
   - Check file ownership in build

## Support

For issues with the add-on:
- GitHub Issues: https://github.com/TheDuke427/gaseous/issues

For issues with Monica itself:
- Monica GitHub: https://github.com/monicahq/monica
- Monica Docs: https://docs.monicahq.com/

## License

This add-on is provided as-is. Monica CRM is licensed under AGPL-3.0.
