class MessageTemplate < ActiveRecord::Base
  acts_as_taggable_on :categories, :platforms

  validates :content, presence: true

  belongs_to :platform
end