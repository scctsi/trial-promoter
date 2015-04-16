class SocialMediaPoster
  include HTTParty

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

  #def get_buffer_profile_ids(formatted_twitter_usernames)
  #  formatted_twitter_usernames.map{ |formatted_twitter_username| get_buffer_profile_id(formatted_twitter_username) }
  #end
  #
  #def publish(update)
  #  body = {
  #      :text => update.text,
  #      :profile_ids => get_buffer_profile_ids(update.social_profiles),
  #      :scheduled_at => update.scheduled_date,
  #      :access_token => "1/2852dbc6f3e36697fed6177f806a2b2f"
  #  }
  #
  #  self.class.post('https://api.bufferapp.com/1/updates/create.json', {:body => body})
  #end
end