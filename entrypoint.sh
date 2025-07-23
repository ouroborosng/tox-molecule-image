#!/bin/bash
set -e

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
exec "$@"
