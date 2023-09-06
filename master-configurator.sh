#!/bin/bash

# Function to create and initialize the main control configuration files
initialize_config_files() {
  config_dir="./Config"

  # Create the Config directory if it doesn't exist
  if [ ! -d "$config_dir" ]; then
    mkdir "$config_dir"
    echo "Created directory: $config_dir"
  fi

  # Create and initialize frontend-config.json if it doesn't exist
  frontend_config_file="$config_dir/frontend-config.json"
  if [ ! -f "$frontend_config_file" ]; then
    cat <<EOF > "$frontend_config_file"
{
  "api": {
    "endpoint": "https://api.example.com",
    "key": "your_api_key_here"
  }
}
EOF
    echo "Created and initialized frontend-config.json."
  fi

   # Create and initialize backend-config.json if it doesn't exist
  backend_config_file="$config_dir/backend-config.json"
  if [ ! -f "$backend_config_file" ]; then
    cat <<EOF > "$backend_config_file"
{
  "app": {
    "name": "Laravel",
    "env": "local",
    "key": "base64:Pneyl10xQ4bex9kA0UzR5VPQTOdmWnEdlg/oKnk6mgQ=",
    "debug": true,
    "url": "http://localhost:3030"
  },
  "log": {
    "channel": "stack",
    "deprecations_channel": "null",
    "level": "debug"
  },
  "db": {
    "connection": "mysql",
    "host": "127.0.0.1",
    "port": 3306,
    "database": "Database",
    "username": "root",
    "password": ""
  },
  "broadcast": {
    "driver": "log"
  },
  "cache": {
    "driver": "file"
  },
  "filesystem": {
    "disk": "local"
  },
  "queue": {
    "connection": "sync"
  },
  "session": {
    "driver": "file",
    "lifetime": 120
  },
  "memcached": {
    "host": "127.0.0.1"
  },
  "redis": {
    "host": "127.0.0.1",
    "password": "null",
    "port": 6379
  },
  "mail": {
    "mailer": "smtp",
    "host": "mailpit",
    "port": 1025,
    "username": "null",
    "password": "null",
    "encryption": "null",
    "from_address": "hello@example.com",
    "from_name": "Laravel"
  },
  "aws": {
    "access_key_id": "",
    "secret_access_key": "",
    "default_region": "us-east-1",
    "bucket": "",
    "use_path_style_endpoint": false
  },
  "pusher": {
    "app_id": "",
    "app_key": "",
    "app_secret": "",
    "host": "",
    "port": 443,
    "scheme": "https",
    "app_cluster": "mt1"
  },
  "vite": {
    "app_name": "Laravel",
    "pusher_app_key": "",
    "pusher_host": "",
    "pusher_port": 443,
    "pusher_scheme": "https",
    "pusher_app_cluster": "mt1"
  }
}
EOF
    echo "Created and initialized backend-config.json."
  fi
}

# Define the backend directory path
backend_dir="backend"

# Function to backup .env and create it from .env.example if it doesn't exist
setup_env() {
  # Check if .env exists in the backend directory
  if [ -f "$backend_dir/.env" ]; then
    # Backup .env and overwrite .env.backup if it exists
    cp "$backend_dir/.env" "$backend_dir/.env.backup"
    echo "$backend_dir/.env backed up to $backend_dir/.env.backup"
  else
    # Create .env from .env.example if it doesn't exist
    if [ -f "$backend_dir/.env.example" ]; then
      cp "$backend_dir/.env.example" "$backend_dir/.env"
      echo "$backend_dir/.env created from $backend_dir/.env.example"
    else
      echo "Error: $backend_dir/.env.example file not found. Cannot create $backend_dir/.env."
      exit 1  # Exit with an error code to indicate a problem
    fi
  fi
}

# Function to revert .env to .env.example
revert_env_to_example() {
  # Check if .env.example exists in the backend directory
  if [ -f "$backend_dir/.env.example" ]; then
    # Revert .env to .env.example in the backend directory
    cp "$backend_dir/.env.example" "$backend_dir/.env"
    echo "$backend_dir/.env has been reverted to $backend_dir/.env.example."
  else
    # Handle the case where .env.example is not found
    echo "Error: $backend_dir/.env.example file not found. Cannot revert $backend_dir/.env."
    exit 1
  fi
}

# Function for frontend configuration
configure_frontend() {
  echo "Configuring frontend..."
  # Add your code for configuring frontend here
}

# Function to configure backend environment variables
configure_backend_env() {
  local backend_config_file="$config_dir/backend-config.json"
  local backend_env_file="$backend_dir/.env"

  # Check if backend-config.json exists
  if [ -f "$backend_config_file" ]; then
    # Parse the JSON file and extract values using jq
    while IFS= read -r line; do
      local key=$(echo "$line" | jq -r '.key')
      local value=$(echo "$line" | jq -r '.value')

      # Update the .env file with the extracted values
      sed -i "s/^$key=.*$/$key=\"$value\"/" "$backend_env_file"
    done < <(jq -c -r 'to_entries[] | {key: .key, value: .value}' "$backend_config_file")

    echo "Backend environment variables configured in $backend_env_file."
  else
    echo "Error: $backend_config_file not found. Cannot configure backend environment variables."
    exit 1
  fi
}

# Call the configure_backend_env function
configure_backend_env

# Main script

# Ensure main control configuration files are created and initialized
initialize_config_files

# Check for the command-line argument to determine which configuration to run
if [ $# -eq 1 ]; then
  case "$1" in
    1)
      echo "Configuring both frontend and backend."
      configure_frontend
      configure_backend_env
      ;;
    2)
      echo "Configuring backend only."
      configure_backend_env
      ;;
    3)
      echo "Configuring frontend only."
      configure_frontend
      ;;
    *)
      echo "Invalid option. Please provide a valid option: 1 (both), 2 (backend), or 3 (frontend)."
      exit 1  # Exit with an error code for an invalid option
      ;;
  esac
else
  echo "Usage: $0 <option>"
  echo "Options:"
  echo "  1 - Configure both frontend and backend"
  echo "  2 - Configure backend only"
  echo "  3 - Configure frontend only"
  exit 1  # Exit with an error code for incorrect usage
fi
