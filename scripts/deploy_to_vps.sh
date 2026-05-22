#!/usr/bin/env bash
set -euo pipefail

HOST="${VPS_HOST:-pqh8temc-vps}"
REPO_URL="${REPO_URL:-$(git config --get remote.origin.url)}"
BRANCH="${BRANCH:-$(git branch --show-current)}"
APP_USER="${APP_USER:-pqhbot}"
APP_DIR="${APP_DIR:-/opt/pqh8temc_bot}"
ENV_DIR="${ENV_DIR:-/etc/pqh8temc_bot}"
ENV_FILE="${ENV_FILE:-$ENV_DIR/pqh8temc_bot.env}"
SERVICE_NAME="${SERVICE_NAME:-pqh8temc-bot}"

if [ -z "$REPO_URL" ]; then
    echo "Missing REPO_URL and no git remote.origin.url is configured" >&2
    exit 1
fi

if [ -z "$BRANCH" ]; then
    BRANCH="main"
fi

ssh "$HOST" \
    "REPO_URL='$REPO_URL' BRANCH='$BRANCH' APP_USER='$APP_USER' APP_DIR='$APP_DIR' ENV_DIR='$ENV_DIR' ENV_FILE='$ENV_FILE' SERVICE_NAME='$SERVICE_NAME' bash -s" <<'REMOTE'
set -euo pipefail

if [ "$(id -u)" -eq 0 ]; then
    SUDO=""
else
    SUDO="sudo"
fi

export DEBIAN_FRONTEND=noninteractive
export GIT_TERMINAL_PROMPT=0

$SUDO apt-get update
$SUDO apt-get install -y git python3-venv python3-pip

if ! id "$APP_USER" >/dev/null 2>&1; then
    $SUDO useradd --system --create-home --home-dir "$APP_DIR" --shell /usr/sbin/nologin "$APP_USER"
fi

$SUDO install -d -m 750 -o root -g "$APP_USER" "$ENV_DIR"
if ! $SUDO test -f "$ENV_FILE"; then
    echo "Missing VPS environment file: $ENV_FILE" >&2
    echo "Create it with TELEGRAM_BOT_TOKEN and DEEPGRAM_API_KEY before deploying." >&2
    exit 1
fi

if [ -d "$APP_DIR/.git" ]; then
    $SUDO chown -R "$APP_USER:$APP_USER" "$APP_DIR"
    $SUDO -u "$APP_USER" git -C "$APP_DIR" remote set-url origin "$REPO_URL"
    $SUDO -u "$APP_USER" git -C "$APP_DIR" fetch --prune origin "$BRANCH"
    $SUDO -u "$APP_USER" git -C "$APP_DIR" checkout -B "$BRANCH" "origin/$BRANCH"
    $SUDO -u "$APP_USER" git -C "$APP_DIR" reset --hard "origin/$BRANCH"
    $SUDO -u "$APP_USER" git -C "$APP_DIR" clean -fd
else
    $SUDO systemctl stop "$SERVICE_NAME" >/dev/null 2>&1 || true
    $SUDO rm -rf "$APP_DIR"
    $SUDO git clone --branch "$BRANCH" --single-branch "$REPO_URL" "$APP_DIR"
    $SUDO chown -R "$APP_USER:$APP_USER" "$APP_DIR"
fi

$SUDO -u "$APP_USER" python3 -m venv "$APP_DIR/.venv"
$SUDO -u "$APP_USER" "$APP_DIR/.venv/bin/python" -m pip install --upgrade pip
$SUDO -u "$APP_USER" "$APP_DIR/.venv/bin/pip" install -r "$APP_DIR/requirements.txt"

$SUDO tee "/etc/systemd/system/$SERVICE_NAME.service" >/dev/null <<SERVICE
[Unit]
Description=PQH8TEMC Telegram bot
After=network-online.target
Wants=network-online.target

[Service]
Type=simple
WorkingDirectory=$APP_DIR
EnvironmentFile=$ENV_FILE
Environment=PYTHONUNBUFFERED=1
ExecStart=$APP_DIR/.venv/bin/python $APP_DIR/bot.py
User=$APP_USER
Group=$APP_USER
Restart=always
RestartSec=5
NoNewPrivileges=true
PrivateTmp=true
ProtectHome=true
ProtectSystem=full
ReadWritePaths=$APP_DIR

[Install]
WantedBy=multi-user.target
SERVICE

$SUDO systemctl daemon-reload
$SUDO systemctl enable "$SERVICE_NAME"
$SUDO systemctl restart "$SERVICE_NAME"

DEPLOYED_SHA="$($SUDO -u "$APP_USER" git -C "$APP_DIR" rev-parse --short HEAD)"
echo "Deployed $DEPLOYED_SHA from $REPO_URL branch $BRANCH"
$SUDO systemctl --no-pager --full status "$SERVICE_NAME"
REMOTE
