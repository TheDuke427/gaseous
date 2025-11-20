#!/usr/bin/with-contenv bashio

# Get config values
DOWNLOAD_PATH=$(bashio::config 'download_path')
IRC_SERVER=$(bashio::config 'irc_server')
IRC_PORT=$(bashio::config 'irc_port')
IRC_NICK=$(bashio::config 'irc_nick')

bashio::log.info "Starting XDCC Downloader..."
bashio::log.info "Downloads will be saved to: ${DOWNLOAD_PATH}"

# Create download directory
mkdir -p "${DOWNLOAD_PATH}"

# Create a simple Python web interface for xdccget
cat > /app.py << 'PYEOF'
from flask import Flask, render_template_string, request, jsonify
import subprocess
import os
import json

app = Flask(__name__)

DOWNLOAD_PATH = os.getenv('DOWNLOAD_PATH', '/media/xdcc-downloads')
IRC_SERVER = os.getenv('IRC_SERVER', 'irc.rizon.net')
IRC_PORT = os.getenv('IRC_PORT', '6667')
IRC_NICK = os.getenv('IRC_NICK', 'xdcc-user')

downloads = []

HTML = """
<!DOCTYPE html>
<html>
<head>
    <title>XDCC Downloader</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; background: #1e1e1e; color: #fff; }
        .container { max-width: 1200px; margin: 0 auto; }
        h1 { color: #4CAF50; }
        .form-group { margin: 15px 0; }
        label { display: block; margin-bottom: 5px; font-weight: bold; }
        input, select { padding: 8px; width: 100%; max-width: 400px; background: #2d2d2d; color: #fff; border: 1px solid #444; }
        button { padding: 10px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; margin: 5px; }
        button:hover { background: #45a049; }
        .downloads { margin-top: 30px; }
        .download-item { background: #2d2d2d; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #4CAF50; }
        .status { display: inline-block; padding: 5px 10px; border-radius: 3px; font-size: 12px; }
        .status-running { background: #2196F3; }
        .status-completed { background: #4CAF50; }
        .status-failed { background: #f44336; }
        .files { margin-top: 30px; }
        .file-item { background: #2d2d2d; padding: 10px; margin: 5px 0; border-radius: 3px; }
        .example { color: #888; font-size: 12px; margin-top: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <h1>XDCC Downloader</h1>
        
        <div class="form-group">
            <label>Server: {{ server }}:{{ port }} | Nick: {{ nick }}</label>
        </div>
        
        <h2>Download File</h2>
        <form id="downloadForm">
            <div class="form-group">
                <label>IRC Channel (with #):</label>
                <input type="text" id="channel" placeholder="#ELITEWAREZ" required>
                <div class="example">Example: #ELITEWAREZ</div>
            </div>
            
            <div class="form-group">
                <label>Bot Name:</label>
                <input type="text" id="bot" placeholder="[EWG]-[TB-IKR09" required>
                <div class="example">Example: [EWG]-[TB-IKR09</div>
            </div>
            
            <div class="form-group">
                <label>Pack Number:</label>
                <input type="text" id="pack" placeholder="1" required>
                <div class="example">Example: 1</div>
            </div>
            
            <button type="submit">Start Download</button>
        </form>
        
        <div class="downloads">
            <h2>Active Downloads</h2>
            <div id="downloadsList"></div>
        </div>
        
        <div class="files">
            <h2>Downloaded Files</h2>
            <button onclick="loadFiles()">Refresh File List</button>
            <div id="filesList"></div>
        </div>
    </div>
    
    <script>
        document.getElementById('downloadForm').onsubmit = async (e) => {
            e.preventDefault();
            const channel = document.getElementById('channel').value;
            const bot = document.getElementById('bot').value;
            const pack = document.getElementById('pack').value;
            
            const response = await fetch('/download', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({channel, bot, pack})
            });
            
            const result = await response.json();
            alert(result.message);
            loadDownloads();
        };
        
        async function loadDownloads() {
            const response = await fetch('/downloads');
            const downloads = await response.json();
            const html = downloads.map(d => `
                <div class="download-item">
                    <strong>${d.bot}</strong> - Pack #${d.pack}
                    <span class="status status-${d.status}">${d.status}</span>
                    <div>${d.channel}</div>
                </div>
            `).join('');
            document.getElementById('downloadsList').innerHTML = html || '<p>No active downloads</p>';
        }
        
        async function loadFiles() {
            const response = await fetch('/files');
            const files = await response.json();
            const html = files.map(f => `
                <div class="file-item">${f}</div>
            `).join('');
            document.getElementById('filesList').innerHTML = html || '<p>No files downloaded yet</p>';
        }
        
        setInterval(loadDownloads, 5000);
        loadDownloads();
        loadFiles();
    </script>
</body>
</html>
"""

@app.route('/')
def index():
    return render_template_string(HTML, server=IRC_SERVER, port=IRC_PORT, nick=IRC_NICK)

@app.route('/download', methods=['POST'])
def download():
    data = request.json
    channel = data.get('channel')
    bot = data.get('bot')
    pack = data.get('pack')
    
    # Start xdccget in background
    cmd = [
        'xdccget',
        '-d', DOWNLOAD_PATH,
        '-s', IRC_SERVER,
        '-p', IRC_PORT,
        '-n', IRC_NICK,
        f"{channel}::{bot}::#{pack}"
    ]
    
    try:
        subprocess.Popen(cmd)
        downloads.append({
            'channel': channel,
            'bot': bot,
            'pack': pack,
            'status': 'running'
        })
        return jsonify({'message': f'Download started for pack #{pack} from {bot}'})
    except Exception as e:
        return jsonify({'message': f'Error: {str(e)}'}), 500

@app.route('/downloads')
def get_downloads():
    return jsonify(downloads)

@app.route('/files')
def get_files():
    try:
        files = os.listdir(DOWNLOAD_PATH)
        return jsonify([f for f in files if not f.startswith('.')])
    except:
        return jsonify([])

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
PYEOF

# Install Flask
pip3 install --no-cache-dir flask --break-system-packages

# Export environment variables for the app
export DOWNLOAD_PATH="${DOWNLOAD_PATH}"
export IRC_SERVER="${IRC_SERVER}"
export IRC_PORT="${IRC_PORT}"
export IRC_NICK="${IRC_NICK}"

bashio::log.info "Starting web interface on port 8080..."
exec python3 /app.py
