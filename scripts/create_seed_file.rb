require 'seed-fu'
require 'csv'

SeedFu::Writer.write('../fixtures/clinical_trials.rb', :class_name => 'ClinicalTrial', :constraints => [:nct_id]) do |writer|
  CSV.foreach("clinical_trials.csv", { :headers=>:first_row }) do |row|
    writer.add(:initial_database_id => row[0], :nct_id => row[1], :pi_name => "#{row[6]} #{row[7]}", :url => "http://clinicaltrials.keckmedicine.org/clinicaltrials/#{row[0]}", :title => row[9])
  end
end