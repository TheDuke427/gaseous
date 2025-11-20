#!/usr/bin/with-contenv bashio

# Get config values
DOWNLOAD_PATH=$(bashio::config 'download_path')

bashio::log.info "Starting XDCC Downloader..."
bashio::log.info "Downloads will be saved to: ${DOWNLOAD_PATH}"

# Create download directory
mkdir -p "${DOWNLOAD_PATH}"

# Create a Python web interface that manages irssi XDCC downloads
cat > /app.py << 'PYEOF'
from flask import Flask, render_template_string, request, jsonify
import subprocess
import os
import threading
import time

app = Flask(__name__)

DOWNLOAD_PATH = os.getenv('DOWNLOAD_PATH', '/media/xdcc-downloads')

downloads = []
active_processes = {}

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
        input, select { padding: 8px; width: 100%; max-width: 400px; background: #2d2d2d; color: #fff; border: 1px solid #444; border-radius: 4px; }
        button { padding: 10px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; margin: 5px; border-radius: 4px; }
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
        
        <h2>Download File</h2>
        <form id="downloadForm">
            <div class="form-group">
                <label>IRC Server:</label>
                <input type="text" id="server" value="irc.rizon.net" required>
                <div class="example">Example: irc.rizon.net, irc.libera.chat</div>
            </div>
            
            <div class="form-group">
                <label>Port:</label>
                <input type="number" id="port" value="6667" required>
            </div>
            
            <div class="form-group">
                <label>Nickname:</label>
                <input type="text" id="nick" value="xdcc-user" required>
                <div class="example">Your IRC nickname</div>
            </div>
            
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
            const server = document.getElementById('server').value;
            const port = document.getElementById('port').value;
            const nick = document.getElementById('nick').value;
            const channel = document.getElementById('channel').value;
            const bot = document.getElementById('bot').value;
            const pack = document.getElementById('pack').value;
            
            const response = await fetch('/download', {
                method: 'POST',
                headers: {'Content-Type': 'application/json'},
                body: JSON.stringify({server, port, nick, channel, bot, pack})
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
                    <div>${d.server} - ${d.channel}</div>
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

def run_xdcc_download(download_id, server, port, nick, channel, bot, pack):
    """Run irssi to download XDCC pack"""
    try:
        # Create irssi config for this download
        config_dir = f"/tmp/irssi-{download_id}"
        os.makedirs(config_dir, exist_ok=True)
        
        # Create irssi script to auto-download
        script = f"""
/set dcc_download_path {DOWNLOAD_PATH}
/set dcc_autoget on
/connect {server} {port}
/nick {nick}
/sleep 3000
/join {channel}
/sleep 3000
/msg {bot} xdcc send #{pack}
/sleep 300000
/quit
"""
        
        script_path = f"{config_dir}/startup.txt"
        with open(script_path, 'w') as f:
            f.write(script)
        
        # Run irssi
        cmd = ['irssi', '--home', config_dir, '--connect', server]
        process = subprocess.Popen(cmd, stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
        
        # Send commands
        time.sleep(2)
        if process.poll() is None:
            process.stdin.write(f"/set dcc_download_path {DOWNLOAD_PATH}\n".encode())
            process.stdin.write(f"/set dcc_autoget on\n".encode())
            process.stdin.write(f"/nick {nick}\n".encode())
            time.sleep(2)
            process.stdin.write(f"/join {channel}\n".encode())
            time.sleep(3)
            process.stdin.write(f"/msg {bot} xdcc send #{pack}\n".encode())
            process.stdin.flush()
        
        # Wait for process or timeout
        process.wait(timeout=300)
        
        # Update status
        for d in downloads:
            if d['id'] == download_id:
                d['status'] = 'completed'
                break
                
    except Exception as e:
        print(f"Download error: {e}")
        for d in downloads:
            if d['id'] == download_id:
                d['status'] = 'failed'
                break

@app.route('/')
def index():
    return render_template_string(HTML)

@app.route('/download', methods=['POST'])
def download():
    data = request.json
    server = data.get('server')
    port = data.get('port')
    nick = data.get('nick')
    channel = data.get('channel')
    bot = data.get('bot')
    pack = data.get('pack')
    
    download_id = len(downloads)
    
    downloads.append({
        'id': download_id,
        'server': server,
        'channel': channel,
        'bot': bot,
        'pack': pack,
        'status': 'running'
    })
    
    # Start download in background thread
    thread = threading.Thread(target=run_xdcc_download, args=(download_id, server, port, nick, channel, bot, pack))
    thread.daemon = True
    thread.start()
    
    return jsonify({'message': f'Download started for pack #{pack} from {bot}'})

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

bashio::log.info "Starting web interface on port 8080..."
exec python3 /app.py
