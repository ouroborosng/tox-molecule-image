#!/bin/bash
set -e

dockerd --host=unix:///var/run/docker.sock &

# Wait until docker daemon successful started
timeout=30
until docker info >/dev/null 2>&1; do
  if [ "$timeout" -le 0 ]; then
    exit 1
  fi
  sleep 1
  timeout=$((timeout - 1))
done

# add safe directory to avoid dubious ownership error
if [ -d "/workspace/.git" ]; then
    git config --global --add safe.directory /workspace
fi

# If no arguments are provided, display usage instructions
if [ $# -eq 0 ]; then
    echo "=== Molecule Tox Runner ==="
    echo "Available commands:"
    echo "  tox                 - Run tox with default configuration"
    echo "  tox -e <env>        - Run specific tox environment"
    echo "  molecule            - Run molecule commands"
    echo "  ansible-lint        - Run ansible linting"
    echo "  yamllint            - Run YAML linting"
fi

# Execute the provided command and arguments
exec su runner -c "$*"
