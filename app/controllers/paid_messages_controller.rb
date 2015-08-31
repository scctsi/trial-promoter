class PaidMessagesController < ApplicationController
  def index
    @facebook_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'paid').order('scheduled_at, message_type, image_required')
    @facebook_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
    @google_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google', 'paid').order('scheduled_at, message_type, image_required')
    @google_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'google_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
    @youtube_search_results_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_search_results', 'paid').order('scheduled_at, message_type, image_required')
    @youtube_uscprofiles_paid_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'youtube_uscprofiles', 'paid').order('scheduled_at, message_type, image_required')
  end
end
