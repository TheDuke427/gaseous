from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
import uvicorn
import os
import sys

# --- Setup for Static File Serving ---
# This assumes the file structure: root/main.py and root/static/index.html
STATIC_DIR = os.path.join(os.path.dirname(__file__), "static")
if not os.path.exists(STATIC_DIR):
    os.makedirs(STATIC_DIR)
    print(f"Created static directory: {STATIC_DIR}")

# --- FastAPI Initialization ---
app = FastAPI(
    title="Dispatcharr Core API",
    description="Backend service for stream and EPG management. (Simulated)",
    version="1.0.0"
)

app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# --- Global State and Utility ---
DEFAULT_PORT = 9500 
APP_PORT = DEFAULT_PORT

@app.on_event("startup")
async def startup_event():
    """Sets the running port for display in the health check."""
    global APP_PORT
    # Simple logic to find or default the port
    if 'uvicorn.main' in sys.modules:
        for i, arg in enumerate(sys.argv):
            if arg == '--port' and i + 1 < len(sys.argv):
                APP_PORT = int(sys.argv[i + 1])
                break
    print(f"Dispatcharr API starting up on port {APP_PORT}...")

# --- Routes ---

@app.get("/", response_class=FileResponse, tags=["Frontend"])
async def serve_index():
    """Serves the main frontend HTML file."""
    return os.path.join(STATIC_DIR, "index.html")

@app.get("/api/health", tags=["System"])
async def get_health_status():
    """Reports the operational status of the backend."""
    return {
        "status": "online",
        "message": "Core API is running smoothly.",
        "port_in_use": APP_PORT
    }

@app.post("/api/m3u_parse", tags=["Streams"])
async def parse_m3u_playlist(m3u_url: str):
    """(Simulated) Initiates the asynchronous parsing of an M3U playlist."""
    print(f"Received M3U URL for parsing: {m3u_url}")
    return {"status": "accepted", "message": f"Parsing job for {m3u_url} started."}

# Note: The if __name__ == "__main__" block is omitted here because we use run.sh/CMD.
