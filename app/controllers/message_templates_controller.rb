class MessageTemplatesController < ApplicationController
  def index
    @twitter_message_templates = MessageTemplate.where(:platform => 'twitter').order('cast(initial_id as int4)')
    @facebook_message_templates = MessageTemplate.where(:platform => 'facebook').order('cast(initial_id as int4)')
    @google_message_templates = MessageTemplate.where(:platform => 'google').order('cast(initial_id as int4)')
    @youtube_search_results_message_templates = MessageTemplate.where(:platform => 'youtube_search_results').order('cast(initial_id as int4)')
  end
end
