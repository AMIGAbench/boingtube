#!/usr/bin/env bash
# BoingTube interactive setup script
#
# This script:
#  - Downloads the official docker-compose.yml from the BoingTube repository
#  - Explains optional YouTube support via yt-dlp
#  - Asks for explicit user consent (YES/NO)
#  - Enables yt-dlp only after explicit opt-in
#
# Using third-party platforms (e.g. YouTube) is subject to their respective
# terms of service. This script does NOT enable anything without consent.

set -euo pipefail

# --------------------------------------------------
# Fixed configuration
# --------------------------------------------------

COMPOSE_URL="https://raw.githubusercontent.com/AMIGAbench/boingtube/refs/heads/main/docker-compose.yml"
COMPOSE_FILE="docker-compose.yml"
ENV_KEY="ENABLE_YTDLP_FETCHER"
DISABLED_VALUE="NO"
ENABLED_VALUE="YES"

# --------------------------------------------------
# Helper functions
# --------------------------------------------------

die() {
  echo "Error: $*" >&2
  exit 1
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

download_compose() {
  echo "Downloading docker-compose.yml from:"
  echo "  $COMPOSE_URL"
  echo
  if have_cmd curl; then
    curl -fsSL "$COMPOSE_URL" -o "$COMPOSE_FILE"
  elif have_cmd wget; then
    wget -qO "$COMPOSE_FILE" "$COMPOSE_URL"
  else
    die "Neither curl nor wget is installed."
  fi
}

ask_yes_no() {
  local answer
  while true; do
    read -r -p "$1 [YES/NO]: " answer
    answer="${answer^^}"
    case "$answer" in
      YES) return 0 ;;
      NO)  return 1 ;;
      *)   echo "Please type YES or NO." ;;
    esac
  done
}

set_env_value() {
  local value="$1"

  if grep -Eq "^[[:space:]]*$ENV_KEY:" "$COMPOSE_FILE"; then
    sed -i -E "s|^([[:space:]]*)$ENV_KEY:[[:space:]]*.*$|\1$ENV_KEY: $value|" "$COMPOSE_FILE"
  else
    die "Could not find $ENV_KEY in $COMPOSE_FILE"
  fi
}

# --------------------------------------------------
# Script start
# --------------------------------------------------

echo
echo "BoingTube setup"
echo "=============="
echo

if [[ -f "$COMPOSE_FILE" ]]; then
  echo "docker-compose.yml already exists."
  if ask_yes_no "Do you want to overwrite it?"; then
    download_compose
  else
    echo "Keeping existing docker-compose.yml"
  fi
else
  download_compose
fi

echo
echo "Optional YouTube support (yt-dlp)"
echo "--------------------------------"
echo
echo "BoingTube does NOT access YouTube by default."
echo
echo "If you enable this option, BoingTube will download and use"
echo "the external tool 'yt-dlp' at container startup to access"
echo "content from third-party platforms such as YouTube."
echo
echo "Use of these platforms is subject to their respective"
echo "terms of service. You are responsible for ensuring that"
echo "your usage complies with those terms."
echo

if ask_yes_no "Do you want to enable optional YouTube support via yt-dlp now?"; then
  echo
  echo "Enabling $ENV_KEY=$ENABLED_VALUE"
  set_env_value "$ENABLED_VALUE"
  YTDLP_STATUS="$ENABLED_VALUE"
else
  echo
  echo "Keeping YouTube support disabled ($ENV_KEY=$DISABLED_VALUE)"
  set_env_value "$DISABLED_VALUE"
  YTDLP_STATUS="$DISABLED_VALUE"
fi

echo
echo "Summary"
echo "-------"
echo "docker-compose.yml configured with:"
echo "  $ENV_KEY=$YTDLP_STATUS"
echo

if have_cmd docker && docker compose version >/dev/null 2>&1; then
  if ask_yes_no "Do you want to start BoingTube now?"; then
    echo
    echo "Starting BoingTube..."
    docker compose up -d
  fi
else
  echo "Docker Compose not found. You can start BoingTube later with:"
  echo "  docker compose up -d"
fi

echo
echo "Setup complete."

