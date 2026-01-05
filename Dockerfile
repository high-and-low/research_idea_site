# ベースイメージ
FROM ruby:3.3-alpine

# 作業ディレクトリ
WORKDIR /app

# 必要なパッケージのインストール
RUN apk add --no-cache \
    build-base \
    sqlite-dev \
    sqlite-libs \
    curl-dev \
    tzdata

# Gemfile と Gemfile.lock をコピー
COPY Gemfile Gemfile.lock ./

# 本番環境用の gem をインストール
RUN bundle config set --local without 'test' && \
    bundle install --jobs 4 --retry 3

# アプリケーションコードをコピー
COPY . .

# 起動スクリプトに実行権限を付与
RUN chmod +x start.sh

# ポート公開
EXPOSE 8080

# 起動コマンド（start.sh を経由）
CMD ["./start.sh"]
