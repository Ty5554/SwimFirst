require "httparty"

class AiService
  include HTTParty
  base_uri "https://api.openai.com/v1"

  def self.get_feedback(content)
    Rails.logger.info "AIService: OpenAI API にリクエストを送信します。"

    response = post("/chat/completions",
      headers: {
        "Authorization" => "Bearer #{Rails.application.credentials.dig(:openai, :api_key)}",
        "Content-Type" => "application/json"
      },
      body: {
        model: "gpt-4o-mini",
        messages: [ { role: "user", content: "あなたは優秀で選手思いの優しい水泳のコーチです。この日誌の感想について、フィードバックを1~2行で返してください: #{content}" } ],
        max_tokens: 100
      }.to_json
    )

    # レスポンスのエンコーディングを明示的に UTF-8 に変換
    body = response.body.force_encoding("UTF-8")
    Rails.logger.info "AIService: OpenAI API レスポンス -> #{body}"

    if response.success?
      JSON.parse(response.body).dig("choices", 0, "message", "content") || "フィードバックの取得に失敗しました"
    else
        Rails.logger.error "AIService: API リクエストが失敗しました。レスポンスコード: #{response.code}, レスポンス内容: #{body}"
        "フィードバックの取得に失敗しました"
    end
  rescue => e
    Rails.logger.error "AIService: 例外が発生しました -> #{e.message}"
    "フィードバックの取得に失敗しました"
  end
end
