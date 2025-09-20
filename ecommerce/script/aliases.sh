#!/bin/sh
#
# Source this file to set up project-specific aliases for the current session.
# Usage: source aliases.sh

alias dl-bexec='docker compose exec web bundle exec'
alias dl-up='docker compose up --build -d --wait'
alias dl-down='docker compose down'
alias dl-logs-web='docker compose logs -f web'
alias dl-exec='docker compose exec web'

# Test aliases
dl-bexec-t() {
  if [ "$1" = "-a" ]; then
    docker compose --profile test run --rm test bundle exec rspec ./spec
  else
    docker compose --profile test run --rm test bundle exec "$@"
  fi
}
alias dl-test='docker compose --profile test run --rm test'
alias dl-test-specific='docker compose --profile test run --rm -e RSPEC_ARGS'

echo "Docker aliases are now active: dl-bexec, dl-up, dl-down, dl-logs-web, dl-exec, dl-bexec-t, dl-test, dl-test-specific"