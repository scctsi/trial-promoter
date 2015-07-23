class MessagesController < ApplicationController
  def index
    @twitter_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ?", 'twitter')
    @facebook_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ?", 'facebook')
  end
end
