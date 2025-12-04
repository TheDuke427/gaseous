# Stage 1: Build stage for dependency installation
FROM python:3.11-slim AS build

# Set the working directory
WORKDIR /app

# Install Dispatcharr dependencies (assuming it's available via pip)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final image stage
FROM python:3.11-slim

# Copy the built dependencies from the build stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the application source code
COPY ./ /app
WORKDIR /app

# Copy the entrypoint script
COPY run.sh /usr/bin/run.sh

# --- FIX: Change permissions AS ROOT user BEFORE switching user ---
# Ensure the script is executable while still running as root.
RUN chmod +x /usr/bin/run.sh

# Create a non-root user for security (Home Assistant best practice)
# This step must come AFTER all root-level file operations (like chmod)
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Expose the default port for Dispatcharr
EXPOSE 9500

# Set the entrypoint
CMD ["/usr/bin/run.sh"]
