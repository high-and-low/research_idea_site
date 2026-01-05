require 'bundler/setup'
require 'sinatra'
require 'sinatra/reloader' if development?
require 'sqlite3'
require 'json'
require 'dotenv/load' if development?
require 'rack/protection'
require_relative 'lib/similarity'
require_relative 'lib/ai_service'

# セッションの有効化
enable :sessions
set :session_secret, ENV['SESSION_SECRET'] || 'a_very_long_and_secure_session_secret_that_is_at_least_64_characters_long_for_rack_session'

# セキュリティ対策
unless ENV['RACK_ENV'] == 'test'
  use Rack::Protection
  use Rack::Protection::AuthenticityToken
end

# データベース接続
set :db_path, ENV['RACK_ENV'] == 'test' ? "db/test_vision_shift.sqlite3" : "db/vision_shift.sqlite3"

helpers do
  def db
    @db ||= SQLite3::Database.new(settings.db_path, results_as_hash: true)
  end

  def h(text)
    Rack::Utils.escape_html(text)
  end

  def extract_tags(text)
    # 正規表現で # から始まるタグを抽出
    text.scan(/#(\w+)/).flatten.uniq.join(',')
  end
end

# --- ルーティング ---

# ダッシュボード (一覧表示)
get '/' do
  @ideas = db.execute("SELECT * FROM ideas ORDER BY created_at DESC")
  erb :index
end

# アイデア登録・検索フォーム
get '/new' do
  erb :new
end

# アイデア保存処理
post '/ideas' do
  title = params[:title]
  content = params[:content]
  tags = extract_tags(content)
  
  # AI 連携 (エンべディング取得)
  ai = AIService.new
  embedding = ai.get_embedding(content)
  embedding_json = embedding ? embedding.to_json : nil

  db.execute("INSERT INTO ideas (title, content, tags, embedding) VALUES (?, ?, ?, ?)",
             [title, content, tags, embedding_json])
  
  session[:message] = "アイデアを保存しました。"
  redirect '/'
end

# 類似度検索
get '/search' do
  @query = params[:query]
  return erb :search if @query.nil? || @query.empty?

  ai = AIService.new
  query_embedding = ai.get_embedding(@query)
  
  @results = []
  if query_embedding
    all_ideas = db.execute("SELECT * FROM ideas")
    all_ideas.each do |idea|
      next unless idea['embedding']
      
      idea_embedding = JSON.parse(idea['embedding'])
      score = Similarity.cosine_similarity(query_embedding, idea_embedding)
      @results << idea.merge('score' => score)
    end
    # スコア順にソート (上位 5件)
    @results = @results.sort_by { |r| -r['score'] }.first(5)
  end

  erb :search
end

# AI リフレーミング画面 (遷移後に JS で AI を呼ぶ)
get '/reframing/:id' do
  @idea = db.execute("SELECT * FROM ideas WHERE id = ?", [params[:id]]).first
  halt 404, "Idea not found" unless @idea
  erb :reframing
end

# AI リフレーミング API (非同期用)
get '/api/reframing/:id' do
  content_type :json
  idea = db.execute("SELECT * FROM ideas WHERE id = ?", [params[:id]]).first
  return { error: "Idea not found" }.to_json unless idea

  ai = AIService.new
  reframing = ai.get_reframing(idea['content'])
  { reframing: reframing }.to_json
end

# エラーハンドリング
error 404 do
  "ページが見つかりません。"
end

error do
  "何らかのエラーが発生しました: #{env['sinatra.error'].message}"
end
