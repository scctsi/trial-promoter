class PaidMessagesController < ApplicationController
  def index
    @facebook_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'paid').order('scheduled_at, message_type')
    @facebook_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook_uscprofiles', 'paid').order('scheduled_at, message_type')
    @google_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google', 'paid').order('scheduled_at, message_type')
    @google_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google_uscprofiles', 'paid').order('scheduled_at, message_type')
    @youtube_search_results_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_search_results', 'paid').order('scheduled_at, message_type')
    @youtube_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_uscprofiles', 'paid').order('scheduled_at, message_type')
  end
end
