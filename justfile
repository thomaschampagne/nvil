set dotenv-load
set shell := ["sh", "-e", "-o", "pipefail", "-c"]

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
  @if [ ! -f .env ]; then \
    echo "Making copy of .env.sample to .env. You may edit it according to your needs."; \
    cp .env.sample .env; \
  fi

# Start and connect to nvil container via zellij
connect: init-env
  @podman machine list | grep -q "Currently running" || podman machine start
  podman compose -f {{compose_file}} up -d
  podman compose -f {{compose_file}} exec {{service}} zsh -ic zellij

# Stop container (preserves volumes/state)
stop:
  podman compose -f {{compose_file}} stop {{service}}

# Delete container stack AND volumes
[confirm("Delete nvil container stack and volumes? (y/n)")]
delete:
  podman compose -f {{compose_file}} down -v