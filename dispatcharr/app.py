from fastapi import FastAPI
from fastapi.staticfiles import StaticFiles
from fastapi.responses import HTMLResponse
from starlette.requests import Request
import os

# Create the FastAPI application instance
app = FastAPI(
    title="Dispatcharr API",
    description="A minimal placeholder for the Dispatcharr Home Assistant Add-on."
)

# --- FIX: Mount static files directory ---
# We assume the frontend files (index.html, css, js) are located in a folder named 'static'
# in the application root (/app). This mounts the /app/static folder to the URL /static.
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.get("/", response_class=HTMLResponse)
def read_root(request: Request):
    """
    Serves the main frontend application (index.html).
    Note: We are manually reading and serving the file since we are not using templates.
    """
    try:
        with open("static/index.html", "r") as f:
            html_content = f.read()
        return HTMLResponse(content=html_content)
    except FileNotFoundError:
        # Fallback to the original health check message if the frontend file is missing
        port = os.environ.get("PORT", "unknown")
        return {
            "status": "online",
            "message": "Dispatcharr is running, but index.html was not found in the static directory.",
            "port_in_use": port
        }

@app.get("/api/health")
def api_health():
    """A dedicated health check endpoint (backend-only)."""
    port = os.environ.get("PORT", "unknown")
    return {
        "status": "online",
        "message": "Backend API is fully operational.",
        "port_in_use": port
    }

# Note: The uvicorn command in run.sh will use 'app:app'
