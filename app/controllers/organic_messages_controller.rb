class OrganicMessagesController < ApplicationController
  def index
    @twitter_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'twitter', 'organic').order('scheduled_at')
    @facebook_organic_messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ?", 'facebook', 'organic').order('scheduled_at')
  end

  def set_image_urls
    message = Message.find(params[:message_id])
    message.image_url = params[:image_url]
    message.thumbnail_url = params[:thumbnail_url]
    message.save

    render :json => {
    }
  end
end
