# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
# This copies main.py and the static/ directory
COPY . .

# Expose the port the app runs on (matching DEFAULT_PORT in main.py)
EXPOSE 9500

# Command to run the application using Uvicorn.
# IMPORTANT CHANGE: The entry point is now 'main:app'
# 'main' refers to main.py, and 'app' refers to the FastAPI instance variable.
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "9500"]
