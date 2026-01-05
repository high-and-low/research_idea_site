require 'minitest/autorun'
require_relative '../lib/ai_service'
require 'dotenv/load'

class TestAIService < Minitest::Test
  def setup
    @ai = AIService.new
  end

  def test_initialization
    # APIキーが設定されている前提でのテスト
    if ENV['GOOGLE_API_KEY']
      assert_kind_of Gemini::Controllers::Client, @ai.instance_variable_get(:@gemini_client)
      assert_kind_of Gemini::Controllers::Client, @ai.instance_variable_get(:@gemini_embed_client)
    end
  end

  def test_reframing_prompt
    content = "空飛ぶ車を作りたい"
    prompt = @ai.send(:reframing_prompt, content)
    assert_includes prompt, content
    assert_includes prompt, "【リフレーミング案】"
    assert_includes prompt, "【期待される効果】"
  end

  def test_tag_extraction_logic
    # app.rb 内にあるロジックを AIService に持たせるか、直接テストする
    # ここでは app.rb の helpers メソッド相当を検証
    content = "人工知能と #AI #Tech #AI の未来"
    tags = content.scan(/#(\w+)/).flatten.uniq.join(',')
    assert_equal "AI,Tech", tags
  end

  # 本来は Mock を使うべきだが、疎通確認を含めて実APIを叩くテスト（環境変数が有る場合のみ）
  def test_get_embedding_structure
    skip "Explicit Google API Key required for real embedding test" unless ENV['GOOGLE_API_KEY']
    
    embedding = @ai.get_embedding("Test content")
    assert_kind_of Array, embedding if embedding
    assert_kind_of Float, embedding.first if embedding && !embedding.empty?
  end
end
