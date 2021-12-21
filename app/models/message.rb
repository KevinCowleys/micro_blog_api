class Message < ApplicationRecord
  belongs_to :conversation
  belongs_to :user, -> { select(:id, :name, :username) }

  validates_presence_of :content, :conversation_id, :user_id

  def message_time
    created_at.strftime("%m/%d/%y at %l:%M %p")
  end
end
