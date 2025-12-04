# Use an official Python runtime as a parent image
FROM python:3.11-slim

# Set the working directory in the container
WORKDIR /app

# Install dependencies
# Copy only the requirements file first to leverage Docker cache
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application files (main.py and static/)
COPY . .

# Copy the startup script and make it executable
COPY run.sh .
RUN chmod +x /app/run.sh

# Expose the port the app runs on (matching DEFAULT_PORT in main.py)
EXPOSE 9500

# IMPORTANT CHANGE: Use the script as the container's entry point.
CMD ["/app/run.sh"]
