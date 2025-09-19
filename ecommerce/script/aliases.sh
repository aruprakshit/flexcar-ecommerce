#!/bin/sh
#
# Source this file to set up project-specific aliases for the current session.
# Usage: source aliases.sh

alias dl-bexec='docker compose exec web bundle exec'
alias dl-up='docker compose up --build -d --wait'
alias dl-down='docker compose down'
alias dl-logs-web='docker compose logs -f web'

echo "Docker aliases are now active: dl-bexec, dl-up, dl-down, dl-logs-web"