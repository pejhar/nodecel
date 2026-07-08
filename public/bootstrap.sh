#!/data/data/com.termux/files/usr/bin/bash

set -e

echo "🚀 Starting Nodecel Laravel Bootstrap..."

PROJECT_DIR="$HOME/nodecel/laravel-app"
REPO_URL="https://github.com/pejhar/nodecel.git"

LOG_DIR="$PROJECT_DIR/storage/logs"


###################################
# Install packages
###################################

echo "📦 Checking packages..."

for pkg in php composer git sqlite curl; do

    if ! command -v $pkg >/dev/null 2>&1; then

        echo "Installing $pkg..."

        pkg install -y $pkg

    fi

done


###################################
# Clone project
###################################

if [ ! -d "$PROJECT_DIR" ]; then

    echo "📥 Cloning Laravel project..."

    mkdir -p "$HOME/nodecel"

    git clone "$REPO_URL" "$PROJECT_DIR"

fi


cd "$PROJECT_DIR"


###################################
# Composer
###################################

if [ ! -d "vendor" ]; then

    echo "📦 Installing Composer packages..."

    composer install \
    --no-interaction \
    --prefer-dist

fi


###################################
# Environment
###################################

if [ ! -f ".env" ]; then

    echo "Creating .env"

    cp .env.example .env

fi


###################################
# Laravel Key
###################################

if ! grep -q "APP_KEY=base64" .env
then

    echo "Generating APP KEY"

    php artisan key:generate --force

fi


###################################
# SQLite
###################################

echo "Setting SQLite..."

mkdir -p database

touch database/database.sqlite


sed -i \
's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' \
.env


sed -i \
's|^DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|' \
.env


###################################
# Queue
###################################

if ! grep -q "^QUEUE_CONNECTION" .env
then

echo "QUEUE_CONNECTION=database" >> .env

fi


###################################
# Migration
###################################

echo "Running migration..."

php artisan migrate --force || true



###################################
# Stop old processes
###################################

echo "Stopping old workers..."

pkill -f "artisan queue:work" 2>/dev/null || true

pkill -f "artisan serve" 2>/dev/null || true



###################################
# Start Queue Worker
###################################

echo "Starting queue worker..."

mkdir -p storage/logs


nohup php artisan queue:work \
--tries=3 \
> storage/logs/queue.log 2>&1 &



###################################
# Get IP
###################################

IP=$(ip route get 1.1.1.1 2>/dev/null \
| awk '{print $7; exit}')


###################################
# Start Laravel
###################################

echo "Starting Laravel Server..."


nohup php artisan serve \
--host=0.0.0.0 \
--port=8000 \
> storage/logs/server.log 2>&1 &



echo ""
echo "================================="
echo "✅ NODECEL SERVER RUNNING"
echo ""
echo "Local:"
echo "http://127.0.0.1:8000"
echo ""
echo "Network:"
echo "http://$IP:8000"
echo ""
echo "Queue:"
echo "RUNNING"
echo ""
echo "================================="
