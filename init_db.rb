require 'sqlite3'
require 'fileutils'

# 本番環境では /app/db がマウントされるため、その中のパスを指定
DB_PATH = "db/vision_shift.sqlite3"

# データベースディレクトリの作成
FileUtils.mkdir_p("db")

db = SQLite3::Database.new(DB_PATH)

# ideas テーブルの作成
db.execute <<-SQL
  CREATE TABLE IF NOT EXISTS ideas (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    content TEXT NOT NULL,
    tags TEXT,
    embedding TEXT, -- JSON 文字列として保存
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP
  );
SQL

puts "Database initialized at #{DB_PATH}"
