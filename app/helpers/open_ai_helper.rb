module OpenAiHelper
  require "net/http"
  require "json"

  def self.call_openai(system_message, messages)
    uri = URI("https://api.openai.com/v1/chat/completions")

    headers = {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{ENV['OPENAI_API_KEY']}"
    }

    full_messages = [{ role: "system", content: system_message }] + messages

    body = {
      model: "gpt-3.5-turbo",
      messages: full_messages
    }

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body.to_json

    response = http.request(request)
    parsed = JSON.parse(response.body)

    parsed.dig("choices", 0, "message", "content")
  end
end
