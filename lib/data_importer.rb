class DataImporter
  include HTTParty

  def import_buffer_data
    Message.where('sent_to_buffer_at is not null').each do |message|
      if !message.buffer_update_id.blank?
        response = HTTParty.get("https://api.bufferapp.com/1/updates/#{message.buffer_update_id}.json?access_token=1/2852dbc6f3e36697fed6177f806a2b2f")

        if response.has_key?('statistics')
          message.statistics = response['statistics']
        end

        if message.sent_from_buffer_at.blank? and response.has_key?('sent_at')
          message.sent_from_buffer_at = DateTime.strptime(response['sent_at'].to_s, '%s')
        end

        if response.has_key?('sent_at')
          message.service_update_id = response['service_update_id']
        end

        message.save
      end
    end
  end

  def process_buffer_data
    if DimensionMetric.where("dimensions = ?", ['twitter', 'organic'].to_yaml).count != 0
      twitter_organic_dimension_metric = DimensionMetric.where("dimensions = ?", ['twitter', 'organic'].to_yaml)[0]
    else
      twitter_organic_dimension_metric = DimensionMetric.new(:dimensions => ['twitter', 'organic'])
    end

    if DimensionMetric.where("dimensions = ?", ['facebook', 'organic'].to_yaml).count != 0
      facebook_organic_dimension_metric = DimensionMetric.where("dimensions = ?", ['facebook', 'organic'].to_yaml)[0]
    else
      facebook_organic_dimension_metric = DimensionMetric.new(:dimensions => ['facebook', 'organic'])
    end

    if DimensionMetric.where("dimensions = ?", ['facebook', 'paid'].to_yaml).count != 0
      facebook_paid_dimension_metric = DimensionMetric.where("dimensions = ?", ['facebook', 'paid'].to_yaml)[0]
    else
      facebook_paid_dimension_metric = DimensionMetric.new(:dimensions => ['facebook', 'paid'])
    end

    twitter_organic_metrics = { 'retweets' => 0, 'favorites' => 0, 'mentions' => 0, 'clicks' => 0, 'reach' => 0 }
    facebook_organic_metrics = { 'comments' => 0, 'likes' => 0, 'reach' => 0, 'shares' => 0, 'clicks' => 0 }
    facebook_paid_metrics = { 'comments' => 0, 'likes' => 0, 'reach' => 0, 'shares' => 0, 'clicks' => 0 }

    Message.where('sent_to_buffer_at is not null and statistics is not null').each do |message|
      if message.message_template.platform.start_with?('twitter')
        twitter_organic_metrics['retweets'] += message.statistics['retweets']
        twitter_organic_metrics['favorites'] += message.statistics['favorites']
        twitter_organic_metrics['mentions'] += message.statistics['mentions']
        twitter_organic_metrics['clicks'] += message.statistics['clicks']
        twitter_organic_metrics['reach'] += message.statistics['reach']
      end

      if message.message_template.platform.start_with?('facebook') and message.medium == 'organic'
        facebook_organic_metrics['comments'] += message.statistics['comments']
        facebook_organic_metrics['likes'] += message.statistics['likes']
        facebook_organic_metrics['reach'] += message.statistics['reach']
        facebook_organic_metrics['shares'] += message.statistics['shares']
        facebook_organic_metrics['clicks'] += message.statistics['clicks']
      end

      if message.message_template.platform.start_with?('facebook') and message.medium == 'paid'
        facebook_paid_metrics['comments'] += message.statistics['comments']
        facebook_paid_metrics['likes'] += message.statistics['likes']
        facebook_paid_metrics['reach'] += message.statistics['reach']
        facebook_paid_metrics['shares'] += message.statistics['shares']
        facebook_paid_metrics['clicks'] += message.statistics['clicks']
      end
    end

    twitter_organic_dimension_metric.metrics = twitter_organic_metrics
    twitter_organic_dimension_metric.save
    facebook_organic_dimension_metric.metrics = facebook_organic_metrics
    facebook_organic_dimension_metric.save
    facebook_paid_dimension_metric.metrics = facebook_paid_metrics
    facebook_paid_dimension_metric.save
  end

  def import_twitter_data
    csv_text = File.read(Rails.root.join('data_dumps', 'twitter_activity_metrics_20150901_20151001.csv'))
    csv = CSV.parse(csv_text, :headers => true)
    csv.each do |row|
      message = Message.where('service_update_id = ?', csv[0].to_s)
      message.service_statistics = { 'retweets' => csv[7], 'favorites' => csv[9], 'replies' => csv[8], 'clicks' => csv[11], 'user_profile_clicks' => csv[10], 'impressions' => csv[4]}
      message.save
    end
  end

  def process_twitter_data
    if DimensionMetric.where("dimensions = ?", ['twitter', 'organic', 'twitter_analytics'].to_yaml).count != 0
      twitter_organic_twitter_analytics_dimension_metric = DimensionMetric.where("dimensions = ?", ['twitter', 'organic', 'twitter_analytics'].to_yaml)[0]
    else
      twitter_organic_twitter_analytics_dimension_metric = DimensionMetric.new(:dimensions => ['twitter', 'organic', 'twitter_analytics'])
    end

    twitter_organic_metrics = { 'retweets' => 0, 'favorites' => 0, 'replies' => 0, 'clicks' => 0, 'user_profile_clicks' => 0, 'impressions' => 0}

    Message.where('sent_to_buffer_at is not null and service_statistics is not null').each do |message|
      twitter_organic_metrics['retweets'] += message.service_statistics['retweets']
      twitter_organic_metrics['favorites'] += message.service_statistics['favorites']
      twitter_organic_metrics['mentions'] += message.service_statistics['replies']
      twitter_organic_metrics['clicks'] += message.service_statistics['clicks']
      twitter_organic_metrics['reach'] += message.service_statistics['user_profile_clicks']
      twitter_organic_metrics['reach'] += message.service_statistics['impressions']
    end

    twitter_organic_twitter_analytics_dimension_metric.metrics = twitter_organic_metrics
    twitter_organic_twitter_analytics_dimension_metric.save
  end
end