desc "This task is called by the Heroku scheduler add-on"

task :update_data => :environment do
  d = DataImporter.new
  d.import_buffer_data
  d.process_buffer_data
  d.import_twitter_data
  d.process_twitter_data
end