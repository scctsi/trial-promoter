require 'seed-fu'
require 'csv'

SeedFu::Writer.write('../db/fixtures/clinical_trials.rb', :class_name => 'ClinicalTrial', :constraints => [:nct_id]) do |writer|
  CSV.foreach("clinical_trials.csv", { :headers=>:first_row }) do |row|
    writer.add(:initial_database_id => row[0], :nct_id => row[1], :pi_name => "#{row[6]} #{row[7]}", :url => "http://clinicaltrials.keckmedicine.org/clinicaltrials/#{row[0]}", :title => row[9])
  end
end

SeedFu::Writer.write('../db/fixtures/twitter_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("twitter_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[2].index('awareness') != nil
    message_type = 'recruiting' if row[2].index('recruiting') != nil

    content = row[4]
    content.gsub! '#disease', '<%= message[:disease_hashtag] %>'
    content.gsub! 'http://bit.ly/1234567', '<%= message[:url] %>'

    writer.add(:initial_id => row[0], :platform => row[1].downcase, :message_type => message_type, :content => content)
  end
end

SeedFu::Writer.write('../db/fixtures/facebook_text_templates.rb', :class_name => 'MessageTemplate', :constraints => [:initial_id, :platform]) do |writer|
  CSV.foreach("facebook_text_templates.csv", { :headers=>:first_row }) do |row|
    message_type = 'awareness' if row[0].to_i <= 30
    message_type = 'recruiting' if row[0].to_i > 30

    content = row[2]
    content.gsub! '#disease', '<%= message[:disease_hashtag] %>'
    content.gsub! 'http://bit.ly/1234567', '<%= message[:url] %>'

    writer.add(:initial_id => row[0], :platform => row[1].downcase, :message_type => message_type, :content => content)
  end
end