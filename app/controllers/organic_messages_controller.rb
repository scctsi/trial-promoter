class OrganicMessagesController < ApplicationController
  def index
    @twitter_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'twitter', 'organic').order('scheduled_at')
    @facebook_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'organic').order('scheduled_at')
  end
end
