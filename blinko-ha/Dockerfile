ARG BUILD_FROM
FROM ${BUILD_FROM}

# Install necessary system packages (python3, pip, and GIT)
RUN apk add --no-cache \
    python3 \
    py3-pip \
    git

# Define the application directory
WORKDIR /app

# Clone the Blinko repository directly into the app directory
RUN git clone https://github.com/blinkospace/blinko.git /app/blinko

# Change into the cloned directory to set the context for the next command
WORKDIR /app/blinko

# Install dependencies from the requirements file located inside the 'blinko' subdirectory,
# plus gunicorn and python-dotenv.
RUN pip3 install --break-system-packages -r blinko/requirements-app.txt \
    gunicorn \
    python-dotenv

# Set the final working directory for the ADD-ON execution
WORKDIR /app

# Copy the run script (this script handles changing to the /app/blinko folder for execution)
COPY run.sh /

# Expose the port for the web interface (required for Ingress)
EXPOSE 8099

# Set the entry point to execute the run script
CMD [ "/run.sh" ]
