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
end