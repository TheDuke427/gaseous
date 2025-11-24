#!/bin/bash

CONFIG_DIR=/config
DASHY_CONFIG_SOURCE="${CONFIG_DIR}/dashy-config.yml"
DASHY_CONFIG_DEST=/app/user-data/conf.yml

# Create config directory if needed
mkdir -p /app/user-data
mkdir -p ${CONFIG_DIR}

# Check if Dashy config exists in /config
if [ ! -f "${DASHY_CONFIG_SOURCE}" ]; then
    echo "[Info] Creating default Dashy configuration with Internal/External sections"
    cat > ${DASHY_CONFIG_SOURCE} <<EOF
pageInfo:
  title: Home Dashboard
  description: Home Assistant Dashboard

appConfig:
  theme: nord
  layout: auto
  iconSize: medium
  customCss: |
    /* Dynamic section collapse based on access method */
    .access-indicator {
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

sections:
  - name: Internal
    icon: fas fa-home
    displayData:
      collapsed: false
      cols: 2
    items:
      - title: Home Assistant
        url: http://192.168.86.32:8123
        icon: fas fa-home
        description: Home Assistant Interface
        target: newtab
      - title: File Editor
        url: http://192.168.86.32:8123/core_configurator
        icon: fas fa-edit
        description: Edit configuration files
        target: newtab
      - title: Supervisor
        url: http://192.168.86.32:8123/hassio/dashboard
        icon: fas fa-cogs
        description: Add-on Management
        target: newtab
      - title: Proxmox
        url: https://192.168.86.32:8006
        icon: fas fa-server
        description: VM Management
        target: newtab
      - title: Router
        url: http://192.168.86.1
        icon: fas fa-network-wired
        description: Network Configuration
        target: newtab
      - title: Portainer
        url: http://192.168.86.32:9000
        icon: fab fa-docker
        description: Docker Management
        target: newtab

  - name: External
    icon: fas fa-globe
    displayData:
      collapsed: true
      cols: 2
    items:
      - title: GitHub
        url: https://github.com
        icon: fab fa-github
        description: Code Repository
        target: newtab
      - title: Cloudflare
        url: https://dash.cloudflare.com
        icon: fas fa-cloud
        description: CDN & DNS
        target: newtab
      - title: Google Drive
        url: https://drive.google.com
        icon: fab fa-google-drive
        description: Cloud Storage
        target: newtab
      - title: Gmail
        url: https://mail.google.com
        icon: fas fa-envelope
        description: Email
        target: newtab
EOF
fi

# Create JavaScript file for dynamic behavior
cat > ${CONFIG_DIR}/dashy-custom.js <<'EOF'
// Auto-collapse sections based on access method
(function() {
    const checkAndToggleSections = () => {
        const isHTTPS = window.location.protocol === 'https:';
        const isLocal = window.location.hostname.includes('192.168') || 
                       window.location.hostname === 'localhost' ||
                       window.location.hostname.includes('.local');
        
        console.log('Access detection - HTTPS:', isHTTPS, 'Local:', isLocal);
        
        // Find all sections
        const sections = document.querySelectorAll('.section');
        
        sections.forEach(section => {
            const titleElem = section.querySelector('.section-title h3, .section-title span');
            if (!titleElem) return;
            
            const title = titleElem.textContent.trim();
            const isCollapsed = section.classList.contains('is-collapsed');
            
            // Determine desired state
            let shouldBeCollapsed;
            if (title === 'Internal') {
                shouldBeCollapsed = isHTTPS; // Collapse Internal on HTTPS
            } else if (title === 'External') {
                shouldBeCollapsed = !isHTTPS; // Collapse External on local
            } else {
                return; // Skip other sections
            }
            
            // Toggle if needed
            if (shouldBeCollapsed !== isCollapsed) {
                const collapseBtn = section.querySelector('.collapse-toggle');
                if (collapseBtn) {
                    console.log('Toggling section:', title);
                    collapseBtn.click();
                }
            }
        });
        
        // Add access indicator
        let indicator = document.querySelector('.access-indicator');
        if (!indicator) {
            indicator = document.createElement('div');
            indicator.className = 'access-indicator';
            document.body.appendChild(indicator);
        }
        indicator.textContent = isHTTPS ? 'EXTERNAL ACCESS' : 'LOCAL ACCESS';
        indicator.style.background = isHTTPS ? '#2196F3' : '#4CAF50';
    };
    
    // Run on load and after Dashy initializes
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', () => {
            setTimeout(checkAndToggleSections, 1500);
        });
    } else {
        setTimeout(checkAndToggleSections, 1500);
    }
    
    // Also check on route changes (for Dashy's Vue router)
    window.addEventListener('popstate', () => {
        setTimeout(checkAndToggleSections, 500);
    });
})();
EOF

# Create a symlink for config persistence
echo "[Info] Linking configuration for persistence"
ln -sf ${DASHY_CONFIG_SOURCE} ${DASHY_CONFIG_DEST}

# Inject the JavaScript into Dashy's index.html if not already done
if ! grep -q "dashy-custom.js" /app/dist/index.html 2>/dev/null; then
    echo "[Info] Injecting custom JavaScript"
    sed -i 's|</body>|<script src="/config/dashy-custom.js"></script></body>|' /app/dist/index.html 2>/dev/null || true
fi

# Make custom JS accessible
ln -sf ${CONFIG_DIR}/dashy-custom.js /app/public/dashy-custom.js 2>/dev/null || true

# Start Dashy
cd /app
exec yarn start
