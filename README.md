# Research Idea Site: 研究アイデア深化支援システム

**Research Idea Site** は、研究者が自身のアイデアを記録し、AI（Gemini/OpenAI）の多角的な視点を通じてそのアイデアをリフレーミング（再解釈）し、深化させるための統合研究支援ツールです。

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Ruby](https://img.shields.io/badge/Ruby-3.3-red.svg)
![Framework](https://img.shields.io/badge/Sinatra-4.2-green.svg)
![AI](https://img.shields.io/badge/AI-Gemini%20%2F%20GPT--4o-orange.svg)

##　主な機能

### 1. アイデア・マネジメント

- シンプルかつ直感的なインターフェースでのアイデア記録
- `#タグ` の自動抽出による整理機能

### 2. AI リフレーミング (AI Analysis)

- **Gemini 1.5 Flash / GPT-4o mini** を活用した多角的な分析
- アイデアに対する「新たな切り口」「批判的視点」「学際的展開」を自動生成
- Markdown 形式で見やすく整形されたレポート

### 3. ベクトル検索・類似度判定

- 最新の埋め込みモデル（Embedding）による意味的な類似度検索
- 過去の自分のアイデアから、関連性の高い思考を呼び戻す「気づき」の提供

### 4. 堅牢なインフラ構成

- **SQLite3** による軽量かつポータブルなデータ管理
- **Docker / Fly.io** へのデプロイに対応
- **GitHub Actions** による自動デプロイパイプライン

## 技術スタック

- **Backend**: Ruby 3.3, Sinatra
- **Database**: SQLite3
- **Frontend**: Tailwind CSS, Vanilla JS, Marked.js (Markdown Rendering)
- **AI**: Google Gemini API (Primary), OpenAI API (Fallback/Embedding)
- **Deployment**: Fly.io, Docker

## セットアップ

### ローカルでの起動

1. **リポジトリをクローンまたはダウンロード**
2. **依存関係のインストール**

    ```bash
    bundle install
    ```

3. **環境変数の設定**
    `.env` ファイルを作成し、以下のキーを設定してください。

    ```env
    GOOGLE_API_KEY=your_gemini_api_key
    OPENAI_API_KEY=your_openai_api_key
    SESSION_SECRET=your_secure_random_string
    ```

4. **データベースの初期化**

    ```bash
    ruby init_db.rb
    ```

5. **起動**

    ```bash
    ruby app.rb
    ```

    `http://localhost:4567` にアクセスします。

## 📁 ディレクトリ構造

- `app.rb`: アプリケーションのメインロジック
- `lib/`:
  - `ai_service.rb`: AI APIとの連携管理
  - `similarity.rb`: ベクトル演算ロジック
- `views/`: ERB テンプレート
- `db/`: SQLite3 データベースファイル
- `init_db.rb`: テーブル初期化スクリプト
- `Dockerfile` / `fly.toml`: デプロイ設定ファイル

## 📝 ライセンス

MIT License
