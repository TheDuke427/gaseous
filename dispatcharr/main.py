from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse, FileResponse
import uvicorn
import os
import signal
import sys
import threading
import time

# --- Setup for Static File Serving ---
# We define the directory where our single HTML file is located.
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

# Mount the static files directory to serve the index.html
# This allows the app to find the HTML, CSS, and JS assets.
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")

# --- Global State and Utility ---
# A variable to track the port the application is running on.
APP_PORT = None
# Define the new default port as requested.
DEFAULT_PORT = 9500 

# --- Application Startup/Shutdown Handlers ---
@app.on_event("startup")
async def startup_event():
    """Initializes the application, finds the port, and sets up health checks."""
    global APP_PORT
    # In a real environment, the port is passed via environment variable or context.
    # We will simulate finding the port here by checking the sys arguments,
    # or assuming the default if running locally via uvicorn.
    try:
        # Check command line arguments for the port
        APP_PORT_FOUND = False
        if 'uvicorn.main' in sys.modules:
            for i, arg in enumerate(sys.argv):
                if arg == '--port' and i + 1 < len(sys.argv):
                    APP_PORT = int(sys.argv[i + 1])
                    APP_PORT_FOUND = True
                    break
        
        if not APP_PORT_FOUND:
             # Fallback assumption for local testing if not found in args
            APP_PORT = DEFAULT_PORT
            
    except Exception:
        # Fallback if any error occurs during argument parsing
        APP_PORT = DEFAULT_PORT
    
    if APP_PORT:
        print(f"Dispatcharr API starting up on port {APP_PORT}...")
    else:
        print("Dispatcharr API starting up...")


@app.on_event("shutdown")
def shutdown_event():
    """Handles graceful shutdown."""
    print("Dispatcharr API shutting down...")


# --- Routes ---

@app.get("/", response_class=FileResponse, tags=["Frontend"])
async def serve_index():
    """Serves the main frontend HTML file."""
    # Ensure the main HTML file is served directly when accessing the root URL.
    return os.path.join(STATIC_DIR, "index.html")


@app.get("/api/health", tags=["System"])
async def get_health_status():
    """Reports the operational status of the backend."""
    return {
        "status": "online",
        "message": "Core API is running smoothly.",
        "port_in_use": APP_PORT if APP_PORT else "Unknown"
    }

# --- Placeholder for core Dispatcharr functionality ---

@app.post("/api/m3u_parse", tags=["Streams"])
async def parse_m3u_playlist(m3u_url: str):
    """(Simulated) Initiates the asynchronous parsing of an M3U playlist."""
    # In the real Dispatcharr, this would queue a job (e.g., using Celery)
    # to fetch, parse, and commit stream data to the database.
    print(f"Received M3U URL for parsing: {m3u_url}")
    return {"status": "accepted", "message": f"Parsing job for {m3u_url} started."}

# --- Main entry point for local execution ---
if __name__ == "__main__":
    # To run this locally: pip install fastapi uvicorn
    # Execute: python main.py
    # Access at: http://127.0.0.1:9500/
    print("Starting Uvicorn server...")
    uvicorn.run(app, host="0.0.0.0", port=DEFAULT_PORT)
