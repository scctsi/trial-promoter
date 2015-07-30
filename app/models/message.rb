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

    clinical_trials_set_1 = nil
    clinical_trials_set_2 = nil
    randomize_clinical_trials(clinical_trials_set_1, clinical_trials_set_2)

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

    (0..(clinical_trials_set_1.length - 1)).each do |i|
      # Organic message + image + awareness message template
      # Organic message + image + recruitment message template

      # -------
      # Twitter
      # -------
      # Organic
      # Awareness
      begin # From set 1 with no image
      end until create_message(clinical_trials_set_1[i], twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
      begin # From set 2 with no image
      end until create_message(clinical_trials_set_2[i], twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', true)
      # Recruiting
      begin # From set 1 with no image
      end until create_message(clinical_trials_set_1[i], twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
      begin # From set 2 with no image
      end until create_message(clinical_trials_set_2[i], twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', true)

      # Twitter will not allow ads for clinical trials
      # # Paid
      # # Awareness
      # begin
      # end until create_message(clinical_trial, twitter_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      #
      # # Recruiting
      # begin
      # end until create_message(clinical_trial, twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # --------
      # Facebook
      # --------
      # Organic
      # Awareness
      # From set 1 with no image
      create_message(clinical_trials_set_1[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')
      # From set 2 with image
      create_message(clinical_trials_set_2[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'organic', true)
      # Recruiting
      # From set 1 with no image
      create_message(clinical_trials_set_1[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic')
      # From set 2 with image
      create_message(clinical_trials_set_2[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic', true)

      # Paid
      # Awareness
      # From set 1 with no image
      create_message(clinical_trials_set_1[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # From set 2 with image
      create_message(clinical_trials_set_2[i], facebook_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid', true)
      # Recruiting
      # From set 1 with no image
      create_message(clinical_trials_set_1[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
      # From set 2 with image
      create_message(clinical_trials_set_2[i], facebook_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid', true)

      # --------
      # Google
      # --------
      # Paid
      # Awareness
      create_message(clinical_trials_set_1[i], google_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trials_set_1[i], google_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')

      # --------
      # YouTube
      # --------
      # Paid
      # Awareness
      create_message(clinical_trials_set_1[i], youtube_search_results_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      create_message(clinical_trials_set_1[i], youtube_search_results_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')

      scheduled_at = scheduled_at + 2

      # Sleep so that the system does not hit Bitly's API limits
      sleep 10
    end

    if !Rails.env.production?
      WebMock.disable_net_connect!
    end
  end

  def self.create_message(clinical_trial, message_template, scheduled_at, medium, image_required = false )
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
    message.image_required = image_required

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

  def self.randomize_clinical_trials(clinical_trials_set_1, clinical_trials_set_2)
    clinical_trials_set_1 = ClinicalTrial.where(:randomization_status => 'Selected').to_a.shuffle

    # Reshuffle while there is atleast one clinical trial that is in the same position as another clinical trial in both sets
    reshuffle = false

    loop do
      clinical_trials_set_2 = clinical_trials_set_1.shuffle

      [0..(clinical_trials_set_1.length - 1)].each_with_index do |clinical_trial, index|
        reshuffle = true if clinical_trials_set_1[index] == clinical_trials_set_2[index]
      end

      break if reshuffle == false
    end
  end
end