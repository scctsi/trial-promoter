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

    clinical_trials_sets = randomize_clinical_trials
    clinical_trials_set_1 = clinical_trials_sets[0]
    clinical_trials_set_2 = clinical_trials_sets[1]

    twitter_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'twitter').to_a
    twitter_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'twitter').to_a
    twitter_uscprofiles_message_templates = MessageTemplate.where(:platform => 'twitter_uscprofiles').to_a
    facebook_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'facebook').to_a
    facebook_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'facebook').to_a
    facebook_uscprofiles_message_templates = MessageTemplate.where(:platform => 'facebook_uscprofiles').to_a
    google_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'google').to_a
    google_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'google').to_a
    google_uscprofiles_message_templates = MessageTemplate.where(:platform => 'google_uscprofiles').to_a
    youtube_search_results_awareness_message_templates = MessageTemplate.where(:message_type => 'awareness', :platform => 'youtube_search_results').to_a
    youtube_search_results_recruiting_message_templates = MessageTemplate.where(:message_type => 'recruiting', :platform => 'youtube_search_results').to_a
    youtube_uscprofiles_message_templates = MessageTemplate.where(:platform => 'youtube_uscprofiles').to_a
    # diseases = clinical_trials_set_1.collect { |clinical_trial| clinical_trial.disease }

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
      end until create_message(clinical_trials_set_1[i], twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic')
      begin # From set 2 with no image
      end until create_message(clinical_trials_set_2[i], twitter_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'organic', true)
      # Profiles Promotion
      begin # No image
      end until create_message(nil, twitter_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

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
      # Profiles Promotion
      create_message(nil, facebook_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'organic')

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
      # Profiles Promotion
      create_message(nil, facebook_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # --------
      # Google
      # --------
      # Paid
      # Awareness
      # From set 1 with no image
      begin
      end until create_message(clinical_trials_set_1[i], google_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      begin
      end until create_message(clinical_trials_set_1[i], google_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
      # Profiles Promotion
      begin
      end until create_message(nil, google_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      # --------
      # YouTube
      # --------
      # Paid
      # Awareness
      begin
      end until create_message(clinical_trials_set_1[i], youtube_search_results_awareness_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')
      # Recruiting
      begin
      end until create_message(clinical_trials_set_1[i], youtube_search_results_recruiting_message_templates.sample(1, random: random)[0], scheduled_at + 1, 'paid')
      # Profiles Promotion
      begin
      end until create_message(nil, youtube_uscprofiles_message_templates.sample(1, random: random)[0], scheduled_at, 'paid')

      scheduled_at = scheduled_at + 2

      # Sleep so that the system does not hit Bitly's API limits
      sleep 15
    end

    if !Rails.env.production?
      WebMock.disable_net_connect!
    end
  end

  def self.create_message(clinical_trial, message_template, scheduled_at, medium, image_required = false )
    message = Message.new
    message.clinical_trial = clinical_trial
    message.message_template = message_template
    message.scheduled_at = scheduled_at
    message.medium = medium
    message.campaign = self.campaign_value
    tracking_url = TrackingUrl.new(message).value(medium, self.campaign_value)
    message.tracking_url = tracking_url
    message.image_required = image_required

    replace_parameters(message)
    # assign_random_image(message) if message.image_required

    if is_valid?(message)
      message.save
      return true
    else
      return false
    end
  end

  def self.replace_parameters(message)
    if !(message.clinical_trial.blank?)
      disease = message.clinical_trial.disease
      pi_name = message.clinical_trial.pi_name
    else
      disease = ''
      pi_name = ''
    end
    url_shortener = UrlShortener.new

    message_template_content = message.message_template.content
    if message.message_template.platform.start_with?('google') || message.message_template.platform.start_with?('youtube')
      message.content = []
      message.content[0] = message.message_template.content[0].gsub('<%= message[:disease] %>', disease)
      message.content[1] = url_shortener.shorten(message.tracking_url)
      message.content[2] = message.message_template.content[1].gsub('<%= message[:disease] %>', disease)
      message.content[3] = message.message_template.content[2].gsub('<%= message[:disease] %>', disease)
      if message.message_template.platform.start_with?('youtube')
        message.content[4] = message.message_template.content[3].gsub('<%= message[:disease] %>', disease)
      end
    else
      message.content = message_template_content.gsub('<%= message[:url] %>', url_shortener.shorten(message.tracking_url))
      message.content = message_template_content.gsub('<%= message[:pi] %>', pi_name)
      tag(message) if !(message.clinical_trial.blank?)
    end
  end

  def self.tag(message)
    message.content = message.content.gsub('<%= message[:disease_hashtag] %>', message.clinical_trial.hashtags[0])
    if !message.clinical_trial.hashtags[1].blank?
      # Always add a secondary hashtag for Facebook messages
      if message.message_template.platform == 'facebook'
        message.content += " #{message.clinical_trial.hashtags[1]}"
      end

      # Add a secondary hashtag for Twitter if possible
      if message.message_template.platform == 'twitter'
        current_message_content = message.content
        message.content += " #{message.clinical_trial.hashtags[1]}"
        message.content = current_message_content if message.content.length > 140
      end
    end
  end

  def self.assign_random_image(message)
    image_names = %w(children_1.png cutout_man.png cutout_woman.png diabetes_magnifier.png faces.png faces_2.png healthy_man.png healthy_woman.png
      healthy_woman_2.png heart.png hero_1.png hero_2.png hero_3.png hero_4.png hero_5.png mother_child.png
      patient.png physician_1.png physician_2.png research.png rope.png stethoscope.png together.png together_2.png together_2b.png)

    random = Random.new

    image = image_names.sample(1, random: random)[0]

    message.thumbnail_url = "http://sc-ctsi.org/trial_promoter/image_pool/#{image}".chomp('.png') + '_thumbnail.png'
    message.image_url = "http://sc-ctsi.org/trial_promoter/image_pool/#{image}"
    message.save(:validate => false)
  end

  def self.campaign_value
    return_value = 'trial-promoter-development'

    if !ENV['CAMPAIGN'].blank?
      return_value  = ENV['CAMPAIGN']
    end

    return(return_value)
  end

  def self.is_valid?(message)
    if message.message_template.platform.start_with?('twitter') && message.content.length > 140
      return false
    end

    if message.message_template.platform.start_with?('google') || message.message_template.platform.start_with?('youtube')
      return false if message.content[0].length > 25 || message.content[1].length > 35 || message.content[2].length > 35
    end

    return true
  end

  def self.randomize_clinical_trials
    clinical_trials_set_1 = ClinicalTrial.where(:randomization_status => 'Selected').to_a.shuffle

    # Reshuffle while there is atleast one clinical trial that is in the same position as another clinical trial in both sets
    reshuffle = false
    clinical_trials_set_2 = clinical_trials_set_1.shuffle
    loop do
      [0..(clinical_trials_set_1.length - 1)].each_with_index do |clinical_trial, index|
        reshuffle = true if clinical_trials_set_1[index] == clinical_trials_set_2[index]
      end

      break if reshuffle == false

      reshuffle = false
      clinical_trials_set_2 = clinical_trials_set_1.shuffle
    end

    return [clinical_trials_set_1, clinical_trials_set_2]
  end

  def permanent_image_url
    # Dropbox thumbnail URLs are of this form: https://api-content.dropbox.com/r11/t/AAANnP_XPBxb28PEfpYSoSap92axlFNxaN4CT4G1i5SKNA/12/307720262/png/_/0/4/children_1.png/CMbg3ZIBIAEgAiADIAQgBSAGIAcoAigH/ps2uob5dswyejiz/AADF_c9_6efgbktZAVxuxLDia/children_1.png?bounding_box=75&mode=fit
    # We pull images from a web location located at sc-ctsi.org/trial_promoter/image_pool
    return "http://sc-ctsi.org/trial_promoter/image_pool/#{thumbnail_url[(thumbnail_url.rindex('/') + 1)..(thumbnail_url.rindex('?') - 1)]}" if !(thumbnail_url.start_with?('http://sc-ctsi.org'))
    image_url
  end
end