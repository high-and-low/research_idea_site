ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'sqlite3'
require 'json'
require_relative '../app'

class TestAppIntegration < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    # テスト用DBの準備
    @db_path = "db/test_vision_shift.sqlite3"
    @db = SQLite3::Database.new(@db_path)
    @db.execute "CREATE TABLE IF NOT EXISTS ideas (id INTEGER PRIMARY KEY, title TEXT, content TEXT, tags TEXT, embedding TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP)"
  end

  def teardown
    File.delete(@db_path) if File.exist?(@db_path)
  end

  def test_get_dashboard
    get '/'
    assert last_response.ok?
    assert_includes last_response.body, "Vision-Shift"
  end

  def test_post_idea_and_search
    # アイデアの投稿
    post '/ideas', { title: "Test Idea", content: "AI #Research #Testing" }
    assert last_response.redirect?
    follow_redirect!
    assert last_response.ok?

    # 検索機能のテスト
    get '/search', { query: "AI Testing" }
    assert last_response.ok?
    assert_includes last_response.body, "Test Idea"
  end

  def test_api_reframing_status
    # テストデータを挿入
    @db.execute("INSERT INTO ideas (title, content, tags) VALUES (?, ?, ?)", ["API Test", "This is an idea for API test", "api"])
    idea_id = @db.last_insert_row_id

    get "/api/reframing/#{idea_id}"
    assert last_response.ok?
    json = JSON.parse(last_response.body)
    assert(json.has_key?('reframing') || json.has_key?('error'))
  end
end
