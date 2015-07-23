class MessageTemplatesController < ApplicationController
  def index
    @twitter_message_templates = MessageTemplate.where(:platform => 'twitter').order(:initial_id)
    @facebook_message_templates = MessageTemplate.where(:platform => 'facebook').order(:initial_id)
  end
end
