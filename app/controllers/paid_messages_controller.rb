class PaidMessagesController < ApplicationController
  def index
    @twitter_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'twitter', 'paid').order('scheduled_at')
    @facebook_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'paid').order('scheduled_at')
    @google_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google', 'paid').order('scheduled_at')
  end
end
