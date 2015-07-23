class Message < ActiveRecord::Base
  validates :content, presence: true

  belongs_to :message_template
  belongs_to :clinical_trial
end