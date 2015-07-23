class MessageTemplate < ActiveRecord::Base
  validates :initial_message_id, presence: true
  validates :content, presence: true
  validates :platform, presence: true
  validates :message_type, presence: true
end