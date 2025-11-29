#!/bin/bash
set -e

echo "Starting Puter..."

cd /opt/puter

npm start -- --port 4100
