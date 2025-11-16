ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install necessary system packages
RUN apk add --no-cache \
    python3 \
    py3-pip

# Copy the Blinko application source code
# Note: Since the Blinko repo is a Python package, we install it using pip directly
# This assumes the 'blinko' package is installable. 
# Alternatively, you could clone the repo and copy the files, but pip is cleaner.

# Install Blinko and its dependencies
RUN pip3 install \
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
