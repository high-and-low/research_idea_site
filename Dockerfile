# ベースイメージ
FROM ruby:3.3-alpine

# 作業ディレクトリ
WORKDIR /app

# 必要なパッケージのインストール
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    tzdata

# Gemfile と Gemfile.lock をコピー
COPY Gemfile Gemfile.lock ./

# 本番環境用の gem をインストール（テスト用は除外）
RUN bundle config set --local without 'test' && \
    bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . .

# データベース初期化（Volume マウント前に実行）
RUN bundle exec ruby db/init.rb

# ポート公開
EXPOSE 8080

# 起動コマンド
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "8080"]
