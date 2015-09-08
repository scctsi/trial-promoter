class SocialMediaPoster
  include HTTParty

  SOCIAL_MEDIA_BUFFER_PROFILE_IDS = {
    'Facebook: USC Clinical Trials Staging' => '55a552df52439f6d7cf80ecb',
    'Facebook: USC Clinical Trials' => '55a551d11205422f5ff80ecd',
    'Twitter: USCTrials' => '55a3fced120542fa11397b99',
    'Twitter: TP_Staging' => '55a3fcc01205424d11fc9170',
    'Facebook: Boosted USC Clinical Trials' => '55c11ce346042c5e7f8ae844',
    'Facebook: Boosted-Staging USC Clinical Trials' => '55c11ce246042c5e7f8ae843'
  }

  def get_buffer_profile_id(formatted_twitter_username)
    # TODO: Move the Access token to secrets.yml
    http_parsed_response = self.class.get("https://api.bufferapp.com/1/profiles.json?access_token=1/2852dbc6f3e36697fed6177f806a2b2f").parsed_response

    formatted_twitter_username = "@#{formatted_twitter_username}" if formatted_twitter_username[0] != '@'
    http_parsed_response.each do |social_profile|
      if social_profile['formatted_username'].downcase == formatted_twitter_username.downcase
        return social_profile['id']
      end
    end

    nil
  end

  def publish(message)
    # TODO: Unit test

    profile_ids = []

    # Twitter
    if message.message_template.platform == 'twitter'
      if message.campaign == 'trial-promoter-staging' || message.campaign == 'trial-promoter-development' # Staging
        profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Twitter: TP_Staging']]
      else # Production
        profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Twitter: USCTrials']]
      end
    end

    # Facebook
    if message.message_template.platform == 'facebook'

      if message.campaign == 'trial-promoter-staging' || message.campaign == 'trial-promoter-development' # Staging

        if message.medium == 'paid' # Paid
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: Boosted-Staging USC Clinical Trials']]
        else # Organic
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: USC Clinical Trials Staging']]
        end

      else # Production

        if message.medium == 'paid' # Paid
          profile_ids = [SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: Boosted USC Clinical Trials']]
        else # Organic
          profile_ids = SOCIAL_MEDIA_BUFFER_PROFILE_IDS['Facebook: USC Clinical Trials']
        end

      end

    end

    scheduled_date = message.scheduled_at.in_time_zone("Pacific Time (US & Canada)").to_date

    # Order is 7:35 AM for clinical trial without image, 8:00 AM for experts posts and 8:35 PM for clinical trial with image
    if !(message.image_required) and (message.message_template.platform.index('uscprofiles') == nil)
      scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 7, 35, 00, '-07:00').in_time_zone("Pacific Time (US & Canada)").utc
    elsif message.message_template.platform.index('uscprofiles') != nil
      scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 8, 00, 00, '-07:00').in_time_zone("Pacific Time (US & Canada)").utc
    else
      scheduled_at = Time.new(scheduled_date.year, scheduled_date.month, scheduled_date.day, 20, 35, 00, '-07:00').in_time_zone("Pacific Time (US & Canada)").utc
    end

    # TODO: Unit test
    body = {
      :text => message.content,
      :profile_ids => profile_ids,
      :access_token => '1/2852dbc6f3e36697fed6177f806a2b2f',
      :scheduled_at => scheduled_at,
      :media => { :photo => message.permanent_image_url, :thumbnail => message.thumbnail_url }
    }

    http_parsed_response = self.class.post('https://api.bufferapp.com/1/updates/create.json', {:body => body}).parsed_response

    message.buffer_update_id = http_parsed_response['updates'][0]['id']
    message.sent_to_buffer_at = Time.now
    message.save
  end

  def publish_pending(platform, medium)
    messages = Message.joins("inner join message_templates on messages.message_template_id = message_templates.id").where("message_templates.platform = ? and messages.medium = ? and DATE(messages.scheduled_at) <= ? and messages.sent_to_buffer_at is null", platform, medium, Time.now.utc.to_date)

    messages.each do |message|
      publish(message)
    end

    return messages.count
  end
end