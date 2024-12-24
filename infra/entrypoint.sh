#!/bin/bash                                                                                                                          
# Exit immediately if a command exits with a non-zero status
set -e

# Log message indicating the script has started
echo "Starting PostgreSQL service..."

# Start the PostgreSQL service
service postgresql start

# Log the status of the PostgreSQL service
if service postgresql status > /dev/null; then
  echo "PostgreSQL service started successfully."
  sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"
else
  echo "Failed to start PostgreSQL service." >&2
  exit 1
fi

# Check if any additional command is provided
if [ $# -gt 0 ]; then
  echo "Executing additional command: $@"
  exec "$@"
else
  echo "No additional command provided. PostgreSQL service is running."
  # Keep the container running
  tail -f /dev/null
fi
