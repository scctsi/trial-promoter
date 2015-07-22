class ClinicalTrial < ActiveRecord::Base
  validates :initial_database_id, :presence => true
  validates :nct_id, :presence => true
  validates :pi_name, :presence => true
  validates :title, :presence => true
  validates :url, :presence => true
end