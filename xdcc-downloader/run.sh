#!/usr/bin/with-contenv bashio

# Get config values
DOWNLOAD_PATH=$(bashio::config 'download_path')

bashio::log.info "Starting XDCC Downloader..."
bashio::log.info "Downloads will be saved to: ${DOWNLOAD_PATH}"

# Create download directory
mkdir -p "${DOWNLOAD_PATH}"

# Create a Python web interface with proper IRC client
cat > /app.py << 'PYEOF'
from flask import Flask, render_template_string, request, jsonify
import socket
import threading
import os
import time
import struct
import re

app = Flask(__name__)

DOWNLOAD_PATH = os.getenv('DOWNLOAD_PATH', '/media/xdcc-downloads')

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
        input, select { padding: 8px; width: 100%; max-width: 400px; background: #2d2d2d; color: #fff; border: 1px solid #444; border-radius: 4px; }
        button { padding: 10px 20px; background: #4CAF50; color: white; border: none; cursor: pointer; margin: 5px; border-radius: 4px; }
        button:hover { background: #45a049; }
        .downloads { margin-top: 30px; }
        .download-item { background: #2d2d2d; padding: 15px; margin: 10px 0; border-radius: 5px; border-left: 4px solid #4CAF50; }
        .status { display: inline-block; padding: 5px 10px; border-radius: 3px; font-size: 12px; }
        .status-connecting { background: #FF9800; }
        .status-requesting { background: #2196F3; }
        .status-downloading { background: #9C27B0; }
        .status-completed { background: #4CAF50; }
        .status-failed { background: #f44336; }
        .files { margin-top: 30px; }
        .file-item { background: #2d2d2d; padding: 10px; margin: 5px 0; border-radius: 3px; }
        .example { color: #888; font-size: 12px; margin-top: 5px; }
        .progress { margin-top: 5px; color: #888; font-size: 12px; }
        .log { background: #1a1a1a; padding: 10px; margin-top: 5px; font-family: monospace; font-size: 11px; max-height: 100px; overflow-y: auto; }
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
                <input type="text" id="pack" placeholder="277" required>
                <div class="example">Example: 277</div>
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
                    ${d.progress ? '<div class="progress">' + d.progress + '</div>' : ''}
                    ${d.logs ? '<div class="log">' + d.logs.join('<br>') + '</div>' : ''}
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
        
        setInterval(loadDownloads, 2000);
        loadDownloads();
        loadFiles();
    </script>
</body>
</html>
"""

class IRCXDCCClient:
    def __init__(self, download_id, server, port, nick, channel, bot, pack):
        self.download_id = download_id
        self.server = server
        self.port = int(port)
        self.nick = nick
        self.channel = channel
        self.bot = bot
        self.pack = pack
        self.sock = None
        self.running = False
        self.logs = []
        
    def log(self, msg):
        self.logs.append(msg)
        print(f"[DL-{self.download_id}] {msg}")
        for d in downloads:
            if d['id'] == self.download_id:
                d['logs'] = self.logs[-10:]  # Keep last 10 log entries
                break
    
    def update_status(self, status, progress=""):
        for d in downloads:
            if d['id'] == self.download_id:
                d['status'] = status
                d['progress'] = progress
                break
    
    def send(self, msg):
        self.sock.send(f"{msg}\r\n".encode('utf-8'))
        self.log(f"SENT: {msg}")
    
    def receive_dcc(self, ip, port, filename, filesize):
        """Handle DCC SEND transfer"""
        try:
            self.update_status('downloading', f'Connecting to DCC server...')
            
            # Convert IP from integer to dotted notation
            ip_str = socket.inet_ntoa(struct.pack('!I', ip))
            self.log(f"Connecting to DCC: {ip_str}:{port}")
            
            # Connect to DCC server
            dcc_sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            dcc_sock.settimeout(30)
            dcc_sock.connect((ip_str, port))
            
            self.log(f"DCC connected, downloading {filename} ({filesize} bytes)")
            
            # Download file
            filepath = os.path.join(DOWNLOAD_PATH, filename)
            received = 0
            
            with open(filepath, 'wb') as f:
                while received < filesize:
                    chunk = dcc_sock.recv(8192)
                    if not chunk:
                        break
                    f.write(chunk)
                    received += len(chunk)
                    
                    # Send acknowledgment
                    dcc_sock.send(struct.pack('!I', received))
                    
                    # Update progress
                    progress_pct = (received / filesize) * 100
                    self.update_status('downloading', f'{filename}: {progress_pct:.1f}% ({received}/{filesize} bytes)')
            
            dcc_sock.close()
            
            if received == filesize:
                self.log(f"Download complete: {filename}")
                self.update_status('completed', f'Downloaded: {filename}')
                return True
            else:
                self.log(f"Incomplete download: {received}/{filesize}")
                self.update_status('failed', f'Incomplete download: {received}/{filesize} bytes')
                return False
                
        except Exception as e:
            self.log(f"DCC error: {str(e)}")
            self.update_status('failed', f'DCC error: {str(e)}')
            return False
    
    def parse_dcc_send(self, line):
        """Parse DCC SEND message with multiple format support"""
        self.log(f"Parsing DCC line: {line}")
        
        try:
            # Try to find DCC SEND in the line
            if 'DCC SEND' not in line.upper():
                return None
            
            # Extract the DCC SEND portion (after :DCC SEND or DCC SEND)
            # Format examples:
            # :bot!user@host PRIVMSG nick :DCC SEND filename ip port filesize
            # :bot!user@host PRIVMSG nick :DCC SEND "filename with spaces" ip port filesize
            
            # Find the actual message content after PRIVMSG
            if ':' in line and 'PRIVMSG' in line:
                # Split on : to get message part
                parts = line.split(':', 2)
                if len(parts) >= 3:
                    message = parts[2]
                else:
                    message = line
            else:
                message = line
            
            self.log(f"Message part: {message}")
            
            # Use regex to parse DCC SEND
            # Pattern: DCC SEND "?filename"? ip port filesize
            pattern = r'DCC SEND\s+("([^"]+)"|(\S+))\s+(\d+)\s+(\d+)\s+(\d+)'
            match = re.search(pattern, message, re.IGNORECASE)
            
            if match:
                filename = match.group(2) if match.group(2) else match.group(3)
                ip = int(match.group(4))
                port = int(match.group(5))
                filesize = int(match.group(6))
                
                self.log(f"Parsed: file={filename}, ip={ip}, port={port}, size={filesize}")
                return (filename, ip, port, filesize)
            else:
                self.log(f"Regex didn't match. Trying simple split...")
                # Fallback: simple split
                parts = message.split()
                if 'SEND' in parts:
                    idx = parts.index('SEND')
                    if len(parts) >= idx + 5:
                        filename = parts[idx + 1].strip('"')
                        ip = int(parts[idx + 2])
                        port = int(parts[idx + 3])
                        filesize = int(parts[idx + 4])
                        self.log(f"Fallback parsed: file={filename}, ip={ip}, port={port}, size={filesize}")
                        return (filename, ip, port, filesize)
                
        except Exception as e:
            self.log(f"Parse error: {str(e)}")
        
        return None
    
    def run(self):
        try:
            self.running = True
            self.update_status('connecting')
            self.log(f"Connecting to {self.server}:{self.port}")
            
            # Connect to IRC server
            self.sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            self.sock.settimeout(300)
            self.sock.connect((self.server, self.port))
            
            # IRC handshake
            self.send(f"NICK {self.nick}")
            self.send(f"USER {self.nick} 0 * :{self.nick}")
            
            buffer = ""
            
            while self.running:
                try:
                    data = self.sock.recv(4096).decode('utf-8', errors='ignore')
                    if not data:
                        break
                    
                    buffer += data
                    lines = buffer.split('\r\n')
                    buffer = lines[-1]
                    
                    for line in lines[:-1]:
                        self.log(f"< {line}")
                        
                        # Handle PING
                        if line.startswith('PING'):
                            self.send(f"PONG {line.split()[1]}")
                        
                        # Check if connected
                        elif '001' in line or '376' in line:
                            self.update_status('requesting')
                            self.send(f"JOIN {self.channel}")
                            time.sleep(2)
                            self.send(f"PRIVMSG {self.bot} :xdcc send #{self.pack}")
                            self.update_status('requesting', 'XDCC request sent, waiting for response...')
                        
                        # DCC SEND offer
                        elif 'DCC SEND' in line.upper():
                            result = self.parse_dcc_send(line)
                            if result:
                                filename, ip, port, filesize = result
                                self.update_status('downloading', f'Receiving: {filename}')
                                
                                if self.receive_dcc(ip, port, filename, filesize):
                                    self.running = False
                                    break
                            else:
                                self.update_status('failed', 'Could not parse DCC SEND message')
                                self.running = False
                
                except socket.timeout:
                    self.log("Timeout")
                    self.update_status('failed', 'Timeout waiting for DCC offer')
                    break
                except Exception as e:
                    self.log(f"Error: {str(e)}")
                    self.update_status('failed', f'Error: {str(e)}')
                    break
            
            self.sock.close()
            
        except Exception as e:
            self.log(f"Connection error: {str(e)}")
            self.update_status('failed', f'Connection error: {str(e)}')

def run_xdcc_download(download_id, server, port, nick, channel, bot, pack):
    client = IRCXDCCClient(download_id, server, port, nick, channel, bot, pack)
    client.run()

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
        'status': 'connecting',
        'progress': '',
        'logs': []
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
