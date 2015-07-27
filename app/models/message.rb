class Message < ActiveRecord::Base
  validates :content, presence: true
  validates :campaign, presence: true
  validates :medium, presence: true

  belongs_to :message_template
  belongs_to :clinical_trial

  def self.generate(start_date)
    # TODO: Unit test


    Message.destroy_all
    scheduled_at = start_date
    clinical_trials = ClinicalTrial.where(:randomization_status => 'Selected')
    twitter_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'twitter').to_a
    twitter_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'twitter').to_a
    facebook_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'facebook').to_a
    facebook_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'facebook').to_a
    random = Random.new
    Bitly.use_api_version_3
    Bitly.configure do |config|
      config.api_version = 3
      config.access_token = '21c4a40d1746ea7d0815aa33a9a3137c50c389e8'
    end
    url_shortener = UrlShortener.new

    if Rails.env != 'production' && Rails.env != 'staging'
      WebMock.allow_net_connect!
    end

    clinical_trials.each do |clinical_trial|
      # Organic message + image + awareness message template
      # Organic message + image + recruitment message template

      # -------
      # Twitter
      # -------
      # Organic
      # Awareness
      create_message(clinical_trial, twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
      # Recruiting
      create_message(clinical_trial, twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

      # Organic
      # Awareness
      create_message(clinical_trial, twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trial, twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # --------
      # Facebook
      # --------
      # Organic
      # Awareness
      create_message(clinical_trial, facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
      # Recruiting
      create_message(clinical_trial, facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

      # Paid
      # Awareness
      create_message(clinical_trial, facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trial, facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      start_date = start_date + 1
    end

    if Rails.env != 'production' && Rails.env != 'staging'
      WebMock.disable_net_connect!
    end
  end

  def create_message(clinical_trial, message_template, scheduled_at, medium )
    campaign = 'trial-promoter-development'
    if Rails.env == 'staging'
      campaign = 'trial-promoter-staging'
    end
    if Rails.env == 'production'
      campaign = 'trial-promoter'
    end

    message = Message.new
    message.clinical_trial = clinical_trial
    message.message_template = message_template
    message.scheduled_at = scheduled_at
    message.medium = medium
    message.campaign = campaign
    tracking_url = TrackingUrl.new(message).value(medium, campaign)
    message.tracking_url = tracking_url
    message.content = message.message_template.content.gsub('<%= message[:url] %>', url_shortener.shorten(tracking_url))
    message.save
  end
end