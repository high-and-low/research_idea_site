#!/bin/sh
# データベースの初期化（Volume が空の場合に実行）
echo "Checking database..."
bundle exec ruby db/init.rb

echo "Starting application..."
# アプリの起動
exec bundle exec rackup --host 0.0.0.0 --port 8080
