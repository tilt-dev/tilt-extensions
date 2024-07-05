#!/bin/bash

# Define the file to store the port number
PORT_FILE=".grip_port"

# Function to find a free port
find_free_port() {
  local port
  while true; do
    port=$(shuf -i 2000-65000 -n 1)
    # Check if the port is free
    if ! ss -lpn | grep ":$port " > /dev/null; then
      echo $port
      return
    fi
  done
}

# Check if a port is provided as an argument
if [ -n "$2" ]; then
  PORT=$2
  # Check if the provided port is free
  if ss -lpn | grep ":$PORT " > /dev/null; then
    echo "Provided port $PORT is already in use. Finding a free port instead."
    PORT=$(find_free_port)
  fi
else
  # Check if the port file exists and read the port from it
  if [ -f "$PORT_FILE" ]; then
    PORT=$(cat "$PORT_FILE")
    # Check if the saved port is free
    if ss -lpn | grep ":$PORT " > /dev/null; then
      echo "Saved port $PORT is already in use. Finding a free port instead."
      PORT=$(find_free_port)
    fi
  else
    # Find a free port if none is provided and no port file exists
    PORT=$(find_free_port)
  fi
fi

# Save the port to the file
echo $PORT > "$PORT_FILE"

# Get the file to be served
FILE=${1:-README.md}

# Run the grip command with the found or provided port and specified file
grip $FILE $PORT -b --quiet

# Output the port number used
echo "Grip is running on port $PORT"
