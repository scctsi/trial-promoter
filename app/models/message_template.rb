class MessageTemplate < ActiveRecord::Base
  validates :content, presence: true
end