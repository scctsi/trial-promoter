require 'seed_fu'

SeedFu::Writer.write('clinical_trial_seeds.rb', :class_name => 'ClinicalTrial', :constraints => [:first_name, :last_name]) do |writer|
  writer.add(:first_name => 'Jon',   :last_name => 'Smith',    :age => 21)
  writer.add(:first_name => 'Emily', :last_name => 'McDonald', :age => 24)
end