class Message < ApplicationRecord
  validates :role, presence: true
  validates :content, presence: true

  def as_openai_format
    { role: role, content: content }
  end
end
