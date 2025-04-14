class EddieController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :load_paths

  def index
    messages = JSON.parse(File.read(@conversation_path), symbolize_names: true)

    respond_to do |format|
      format.html
      format.json { 
        render json: { messages: messages }
    }
    end
  end

  def create
    user_input = params[:message]

    # Load system and history
    system_prompt = File.read(@system_path)
    messages = JSON.parse(File.read(@conversation_path), symbolize_names: true)

    # Append user message
    messages << { role: "user", content: user_input }

    # Send to OpenAI
    response = OpenAiHelper.call_openai(system_prompt, messages)

    # Append assistant reply
    assistant_message = { role: "assistant", content: response }
    messages << assistant_message

    # Save updated conversation
    File.write(@conversation_path, JSON.pretty_generate(messages))

    render json: assistant_message
  end

  private

  def load_paths
    @system_path = Rails.root.join("app/assets/ai/system.txt")
    @conversation_path = Rails.root.join("app/assets/ai/conversation.json")
  end
end
