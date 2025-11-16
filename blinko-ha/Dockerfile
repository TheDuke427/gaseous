ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install necessary system packages (python3, pip, and GIT)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git

# --- Start of new strategy ---

# Define the application directory
WORKDIR /app

# Clone the Blinko repository directly into the app directory
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# Change into the cloned directory
WORKDIR /app/blinko

# Install dependencies from the requirements.txt file found inside the repo,
# plus the necessary packages for running the Flask server (gunicorn, python-dotenv).
RUN pip3 install --break-system-packages -r requirements.txt \
    gunicorn \
    python-dotenv

# --- End of new strategy ---

# Set the final working directory to the application's root folder
WORKDIR /app

# The run.sh script must now reference the application files inside the /app/blinko folder.
# Copy the run script
COPY run.sh /

# Expose the port for the web interface (required for Ingress)
EXPOSE 8099

# Set the entry point
CMD [ "/run.sh" ]
