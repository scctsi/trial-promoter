class Platform < ActiveRecord::Base
  validates :name, presence: true
  validates :medium, presence: true

  has_many :message_templates
end