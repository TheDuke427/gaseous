#!/bin/bash

CONFIG_DIR=/config
DASHY_CONFIG_SOURCE="${CONFIG_DIR}/dashy-config.yml"
DASHY_CONFIG_DEST=/app/user-data/conf.yml
CUSTOM_CSS="${CONFIG_DIR}/custom.css"

# Create config directory if needed
mkdir -p /app/user-data

# Create custom CSS with JavaScript for dynamic behavior
if [ ! -f "${CUSTOM_CSS}" ]; then
    echo "[Info] Creating custom CSS with dynamic collapse logic"
    cat > ${CUSTOM_CSS} <<'EOF'
/* Custom styles for Dashy */

/* Add this JavaScript that runs on page load */
<script>
window.addEventListener('DOMContentLoaded', function() {
    // Check if accessing via HTTPS or local IP
    const isHTTPS = window.location.protocol === 'https:';
    const isLocal = window.location.hostname.startsWith('192.168') || 
                    window.location.hostname === 'localhost' ||
                    window.location.port === '4000';
    
    // Wait a bit for Dashy to fully load
    setTimeout(() => {
        // Find sections by their titles
        const sections = document.querySelectorAll('.section');
        
        sections.forEach(section => {
            const title = section.querySelector('.section-title')?.textContent?.trim();
            const collapseBtn = section.querySelector('.collapse-toggle');
            
            if (title === 'Internal') {
                // Internal section: expand on local, collapse on HTTPS
                if (isHTTPS && !section.classList.contains('is-collapsed')) {
                    collapseBtn?.click();
                } else if (isLocal && section.classList.contains('is-collapsed')) {
                    collapseBtn?.click();
                }
            } else if (title === 'External') {
                // External section: collapse on local, expand on HTTPS
                if (isLocal && !section.classList.contains('is-collapsed')) {
                    collapseBtn?.click();
                } else if (isHTTPS && section.classList.contains('is-collapsed')) {
                    collapseBtn?.click();
                }
            }
        });
    }, 1000);
});
</script>

<style>
/* Optional: Add visual indicators for which environment you're in */
body::before {
    content: "LOCAL ACCESS";
    position: fixed;
    top: 5px;
    right: 5px;
    background: #4CAF50;
    color: white;
    padding: 2px 8px;
    border-radius: 3px;
    font-size: 10px;
    z-index: 9999;
    opacity: 0.7;
}

body.https-access::before {
    content: "EXTERNAL ACCESS";
    background: #2196F3;
}
</style>

<script>
// Add class to body based on access method
if (window.location.protocol === 'https:') {
    document.body.classList.add('https-access');
}
</script>
EOF
fi

# Check if Dashy config exists in /config
if [ ! -f "${DASHY_CONFIG_SOURCE}" ]; then
    echo "[Info] Creating default Dashy configuration with Internal/External sections"
    cat > ${DASHY_CONFIG_SOURCE} <<EOF
pageInfo:
  title: Home Dashboard
  description: Home Assistant Dashboard
  customStyles:
    - /config/custom.css

appConfig:
  theme: nord
  layout: auto
  iconSize: medium

sections:
  - name: Internal
    icon: fas fa-home
    displayData:
      collapsed: false
    items:
      - title: Home Assistant
        url: http://192.168.86.32:8123
        icon: fas fa-home
        description: Home Assistant Interface
      - title: Proxmox
        url: https://192.168.86.32:8006
        icon: fas fa-server
        description: Proxmox Management
      - title: Router Admin
        url: http://192.168.86.1
        icon: fas fa-network-wired
        description: Router Configuration

  - name: External
    icon: fas fa-globe
    displayData:
      collapsed: true
    items:
      - title: GitHub
        url: https://github.com
        icon: fab fa-github
        description: GitHub Repository
      - title: Cloudflare
        url: https://dash.cloudflare.com
        icon: fas fa-cloud
        description: Cloudflare Dashboard
      - title: Google Drive
        url: https://drive.google.com
        icon: fab fa-google-drive
        description: Cloud Storage
EOF
fi

# Create a symlink for config persistence
echo "[Info] Linking configuration for persistence"
ln -sf ${DASHY_CONFIG_SOURCE} ${DASHY_CONFIG_DEST}

# Also symlink the custom CSS to be accessible
ln -sf ${CUSTOM_CSS} /app/public/custom.css

# Start Dashy
cd /app
exec yarn start
