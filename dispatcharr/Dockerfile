# Stage 1: Build stage for dependency installation
FROM python:3.11-slim AS build

# Set the working directory
WORKDIR /app

# Install Dispatcharr dependencies (assuming it's available via pip)
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Stage 2: Final image stage
FROM python:3.11-slim

# Install necessary packages for the runtime (if any)
# We assume the Python base image has everything needed, otherwise add:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     ... \
#     && rm -rf /var/lib/apt/lists/*

# Copy the built dependencies from the build stage
COPY --from=build /usr/local/lib/python3.11/site-packages /usr/local/lib/python3.11/site-packages

# Copy the application source code
COPY ./ /app
WORKDIR /app

# Create a non-root user for security (Home Assistant best practice)
RUN groupadd -r appuser && useradd -r -g appuser appuser
USER appuser

# Expose the default port for Dispatcharr
EXPOSE 9500

# Copy the entrypoint script
COPY run.sh /usr/bin/run.sh
RUN chmod +x /usr/bin/run.sh

# Set the entrypoint
CMD ["/usr/bin/run.sh"]
