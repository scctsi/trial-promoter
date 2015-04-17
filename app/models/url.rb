class Url < ActiveRecord::Base
  validates :value, presence: true
end