#!/bin/bash

# Default values
verbose=false

# Function to display usage
usage() {
  echo "Usage: $0 [-v|--verbose] [-h|--help]"
  exit 1
}

# Parse the command-line options
while [[ $# -gt 0 ]]; do
  case "$1" in
    -v|--verbose)
      verbose=true
      shift
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1"
      usage
      ;;
  esac
done

# Main logic
if $verbose; then
  echo "Verbose mode enabled."
else
  echo "Verbose mode disabled."
fi
