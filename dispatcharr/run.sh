#!/bin/bash

# --- Startup script for the Dispatcharr Core API ---

# The application runs on port 9500 as defined in main.py
PORT=9500

# Start Uvicorn, explicitly referencing the main.py file and the 'app' variable.
echo "Starting Dispatcharr API server on port $PORT..."
exec uvicorn main:app --host 0.0.0.0 --port $PORT
