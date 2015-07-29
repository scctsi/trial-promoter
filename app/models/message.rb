class Message < ActiveRecord::Base
  serialize :content

  validates :content, presence: true
  validates :campaign, presence: true
  validates :medium, presence: true

  belongs_to :message_template
  belongs_to :clinical_trial

  def self.generate(start_date = DateTime.now)
    # TODO: Unit test
    Message.destroy_all

    Bitly.use_api_version_3
    Bitly.configure do |config|
      config.api_version = 3
      config.access_token = '21c4a40d1746ea7d0815aa33a9a3137c50c389e8'
    end

    scheduled_at = start_date
    clinical_trials = ClinicalTrial.where(:randomization_status => 'Selected')
    twitter_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'twitter').to_a
    twitter_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'twitter').to_a
    facebook_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'facebook').to_a
    facebook_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'facebook').to_a
    google_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'google').to_a
    google_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'google').to_a
    youtube_search_results_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'youtube_search_results').to_a
    youtube_search_results_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'youtube_search_results').to_a
    random = Random.new

    if !Rails.env.production?
      WebMock.allow_net_connect!
    end

    clinical_trials.each do |clinical_trial|
      # Organic message + image + awareness message template
      # Organic message + image + recruitment message template

      message_created_successfully = false

      # -------
      # Twitter
      # -------
      # Organic
      # Awareness
      begin
      end until create_message(clinical_trial, twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

      # Recruiting
      begin
      end until create_message(clinical_trial, twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

      # Paid
      # Awareness
      begin
      end until create_message(clinical_trial, twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # Recruiting
      begin
      end until create_message(clinical_trial, twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

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

      # --------
      # Google
      # --------
      # Paid
      # Awareness
      create_message(clinical_trial, google_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trial, google_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # --------
      # YouTube
      # --------
      # Paid
      # Awareness
      create_message(clinical_trial, youtube_search_results_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trial, youtube_search_results_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      scheduled_at = scheduled_at + 1

      # Sleep so that the system does not hit Bitly's API limits
      sleep 10
    end

    if !Rails.env.production?
      WebMock.disable_net_connect!
    end
  end

  def self.create_message(clinical_trial, message_template, scheduled_at, medium )
    campaign = 'trial-promoter-development'
    if !ENV['CAMPAIGN'].blank?
      campaign = ENV['CAMPAIGN']
    end

    message = Message.new
    message.clinical_trial = clinical_trial
    message.message_template = message_template
    message.scheduled_at = scheduled_at
    message.medium = medium
    message.campaign = campaign
    tracking_url = TrackingUrl.new(message).value(medium, campaign)
    message.tracking_url = tracking_url

    replace_parameters(message)

    if is_valid?(message)
      message.save
      return true
    else
      return false
    end
  end

  def self.replace_parameters(message)
    url_shortener = UrlShortener.new

    message_template_content = message.message_template.content
    if message.message_template.platform == 'google' || message.message_template.platform == 'youtube_search_results'
      message.content = []
      message.content[0] = message.message_template.content[0].gsub('<%= message[:disease] %>', message.clinical_trial.disease)
      message.content[1] = url_shortener.shorten(message.tracking_url)
      message.content[2] = message.message_template.content[1].gsub('<%= message[:disease] %>', message.clinical_trial.disease)
      message.content[3] = message.message_template.content[2].gsub('<%= message[:disease] %>', message.clinical_trial.disease)
    else
      message.content = message_template_content.gsub('<%= message[:url] %>', url_shortener.shorten(message.tracking_url))
      message.content = message.content.gsub('<%= message[:disease_hashtag] %>', message.clinical_trial.hashtags[0])
    end
  end

  def self.is_valid?(message)
    if message.message_template.platform == 'twitter' && message.content.length > 140
      return false
    end

    if message.message_template.platform == 'google' || message.message_template.platform == 'youtube_search_results'
      return false if message.content[0].length > 25 || message.content[1].length > 35 || message.content[2].length > 35
    end

    return true
  end
end