set dotenv-load
set shell := ["sh", "-eu", "-o", "pipefail", "-c"]

compose_file := ".nvil.yaml"
service := "nvil"

# Quick aliases
alias c := connect
alias s := stop
alias d := delete

# List all available commands
[default]
list:
  @just --list

# Copy .env.sample to .env if missing (run once)
init-env:
  test -f .env || echo -e "\nMaking copy of .env.sample to .env. You may edit it accodring your needs.\n" && cp .env.sample .env

# Start and connect to nvil container via zellij
connect: init-env
  podman machine start || true
  podman compose -f {{compose_file}} up -d
  podman compose -f {{compose_file}} exec {{service}} zsh -ic zellij

# Stop container (preserves volumes/state)
stop:
  podman compose -f {{compose_file}} stop {{service}}

# Delete container stack and volumes
[confirm("Delete nvil container stack and volumes?")]
delete:
  podman compose -f {{compose_file}} down
