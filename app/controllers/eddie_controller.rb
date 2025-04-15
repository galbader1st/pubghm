class EddieController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_paths

  def index
    messages = Message.order(:created_at).map(&:as_openai_format)

    respond_to do |format|
      format.html
      format.json { 
        render json: { messages: messages }
    }
    end
  end

  def create
    user_input = params[:message]
    Message.create!(role: 'user', content: user_input)

    # Load system and history
    system_prompt = File.read(@system_path)
    messages = Message.order(:created_at).map(&:as_openai_format)

    # Send to OpenAI
    response = OpenAiHelper.call_openai(system_prompt, messages)

    # Append assistant reply
    assistant_message = { role: "assistant", content: response }
    Message.create!(role: 'assistant', content: response)

    render json: assistant_message
  end

  private

  def load_paths
    @system_path = Rails.root.join("app/assets/ai/system.txt")
    @conversation_path = Rails.root.join("app/assets/ai/conversation.json")
  end
end
