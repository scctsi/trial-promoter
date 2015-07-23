class MessageTemplatesController < ApplicationController
  def index
    @twitter_message_templates = MessageTemplate.where(:platform => 'twitter')
    @facebook_message_templates = MessageTemplate.where(:platform => 'facebook')
  end
end
