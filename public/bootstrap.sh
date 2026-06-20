#!/data/data/com.termux/files/usr/bin/bash

set -e

PROJECT_DIR="$HOME/nodecel/laravel-app"
REPO_URL="https://github.com/pejhar/nodecel.git"

echo "🚀 Starting Laravel Bootstrap..."

# نصب پیش‌نیازها
for pkg in php composer git sqlite; do
    if ! command -v $pkg >/dev/null 2>&1; then
        echo "📦 Installing $pkg..."
        pkg install -y $pkg
    fi
done

# اگر پروژه وجود ندارد clone کن
if [ ! -d "$PROJECT_DIR" ]; then
    echo "📥 Cloning project..."
    git clone "$REPO_URL" "$PROJECT_DIR"
fi

cd "$PROJECT_DIR"

# نصب dependencies فقط بار اول
if [ ! -d "vendor" ]; then
    echo "📦 composer install..."
    composer install --no-interaction
fi

# env
if [ ! -f ".env" ]; then
    cp .env.example .env
fi

# key
if ! grep -q "APP_KEY=base64" .env; then
    php artisan key:generate --force
fi

# sqlite
mkdir -p database
touch database/database.sqlite

# config DB
sed -i 's/^DB_CONNECTION=.*/DB_CONNECTION=sqlite/' .env
sed -i 's|^DB_DATABASE=.*|DB_DATABASE=database/database.sqlite|' .env

# queue
if ! grep -q "QUEUE_CONNECTION" .env; then
    echo "QUEUE_CONNECTION=database" >> .env
fi

# migrations
php artisan migrate --force

# stop old workers
pkill -f "artisan queue:work" 2>/dev/null || true

# queue worker
nohup php artisan queue:work > storage/logs/queue.log 2>&1 &

# IP
IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{print $7; exit}')

echo "=================================="
echo "App running:"
echo "http://127.0.0.1:8000"
echo "http://$IP:8000"
echo "=================================="

php artisan serve --host=0.0.0.0 --port=8000