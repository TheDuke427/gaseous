ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install necessary system packages (python3, pip, and GIT)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git

# Install Blinko and its dependencies, forcing installation past PEP 668 protection
RUN pip3 install --break-system-packages \
    git+https://github.com/blinkospace/blinko.git@main \
    gunicorn \
    python-dotenv

# Define the working directory
WORKDIR /app

# Expose the port for the web interface (required for Ingress)
EXPOSE 8099

# Copy the run script
COPY run.sh /

# Set the entry point
CMD [ "/run.sh" ]
