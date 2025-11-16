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

# *** NEW STEP: List contents of the root and nested directory to debug the file path ***
RUN ls -R /app/blinko

# Change the working directory to the *most likely* source folder.
WORKDIR /app/blinko/blinko

# Install dependencies from the requirements file.
# We are currently attempting the assumption that the file is here:
RUN pip3 install --break-system-packages -r requirements-app.txt \
    gunicorn \
    python-dotenv

# Set the final working directory for the ADD-ON execution (where run.sh expects files)
WORKDIR /app

# Copy the run script
COPY run.sh /

# Expose the port for the web interface (required for Ingress)
EXPOSE 8099

# Set the entry point to execute the run script
CMD [ "/run.sh" ]
