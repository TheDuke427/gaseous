ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install necessary system packages (python3, pip, and GIT)
# This uses the Home Assistant base image's package manager (apk)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git

# Define the application directory
WORKDIR /app

# Clone the Blinko repository directly into the app directory
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# Change into the cloned directory to access the requirements file
WORKDIR /app/blinko

# Install dependencies from the requirements-app.txt file (the correct filename),
# plus gunicorn and python-dotenv for running the Flask server and handling environment variables.
# --break-system-packages is used to override PEP 668 and install into the container's environment.
RUN pip3 install --break-system-packages -r requirements-app.txt \
    gunicorn \
    python-dotenv

# Set the final working directory to the application's root folder
WORKDIR /app

# Copy the run script
COPY run.sh /

# Expose the port for the web interface (required for Ingress)
EXPOSE 8099

# Set the entry point to execute the run script
CMD [ "/run.sh" ]
