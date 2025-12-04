from fastapi import FastAPI
import os

# Create the FastAPI application instance
app = FastAPI(
    title="Dispatcharr API",
    description="A minimal placeholder for the Dispatcharr Home Assistant Add-on."
)

@app.get("/")
def read_root():
    """A simple health check endpoint."""
    port = os.environ.get("PORT", "unknown")
    return {
        "status": "online",
        "message": "Dispatcharr is running successfully!",
        "port_in_use": port
    }

# Note: The uvicorn command in run.sh will use 'app:app'
