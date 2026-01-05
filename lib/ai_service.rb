require 'openai'
require 'gemini-ai'
require 'dotenv/load'

class AIService
  def initialize
    @openai_client = OpenAI::Client.new(access_token: ENV['OPENAI_API_KEY']) if ENV['OPENAI_API_KEY']
    # Gemini コンテンツ生成用
    @gemini_client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY'],
        version: 'v1beta'
      },
      options: { model: 'gemini-2.5-flash' }
    ) if ENV['GOOGLE_API_KEY']

    # Gemini エンべディング用
    @gemini_embed_client = Gemini.new(
      credentials: {
        service: 'generative-language-api',
        api_key: ENV['GOOGLE_API_KEY'],
        version: 'v1beta'
      },
      options: { model: 'text-embedding-004' }
    ) if ENV['GOOGLE_API_KEY']
  end

  # テキストをベクトル化
  def get_embedding(text)
    # まず OpenAI を試行
    if @openai_client
      begin
        response = @openai_client.embeddings(
          parameters: {
            model: "text-embedding-3-small",
            input: text
          }
        )
        embedding = response.dig("data", 0, "embedding")
        return embedding if embedding
      rescue => e
        puts "OpenAI Embedding Error: #{e.message}. Falling back to Gemini if available."
      end
    end

    # OpenAI が失敗または利用不可の場合、Gemini を試行
    if @gemini_embed_client
      begin
        result = @gemini_embed_client.embed_content({
          content: { parts: [{ text: text }] }
        })
        return result.dig('embedding', 'values')
      rescue => e
        puts "Gemini Embedding Error: #{e.message}"
      end
    end

    nil
  end

  # リフレーミング提案を生成
  def get_reframing(idea_content)
    # Gemini が利用可能な場合は、OpenAI よりも先に（またはエラー時の代替として）検討
    if @gemini_client
      begin
        return get_gemini_reframing(idea_content)
      rescue => e
        puts "Gemini Error: #{e.message}. Falling back to OpenAI if available."
      end
    end

    return "APIキーが設定されていないため、提案を生成できません。OpenAI の 429 エラーが発生した場合は、Google Gemini の API キー設定もご検討ください。" unless @openai_client

    prompt = reframing_prompt(idea_content)

    response = @openai_client.chat(
      parameters: {
        model: "gpt-4o",
        messages: [{ role: "user", content: prompt }],
        temperature: 0.7
      }
    )
    response.dig("choices", 0, "message", "content")
  rescue => e
    "AI提案の生成中にエラーが発生しました: #{e.message}"
  end

  private

  def reframing_prompt(content)
    <<~PROMPT
      あなたは HCI (Human-Computer Interaction) とメディアアートの専門家です。
      以下のアイデアを読み、SCAMPER法に基づいた「リフレーミング（視点の転換）」を1つ提案してください。
      特に、モダリティ（感覚）の変換や、使用文脈の転換に焦点を当ててください。

      アイデア内容:
      #{content}

      回答は以下の形式で簡潔にお願いします：
      【リフレーミング案】
      [具体的な提案内容]
      【期待される効果】
      [その提案によってどのような新しい体験や問いが生まれるか]
    PROMPT
  end

  def get_gemini_reframing(content)
    prompt = reframing_prompt(content)
    result = @gemini_client.generate_content({
      contents: { role: 'user', parts: { text: prompt } }
    })
    result.dig('candidates', 0, 'content', 'parts', 0, 'text')
  end
end
