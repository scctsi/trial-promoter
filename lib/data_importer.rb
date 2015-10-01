class DataImporter
  include HTTParty

  def import_buffer_data
    Message.where('sent_to_buffer_at is not null').each do |message|
      if !message.buffer_update_id.blank?
        response = HTTParty.get("https://api.bufferapp.com/1/updates/#{message.buffer_update_id.to_s}.json?access_token=1/2852dbc6f3e36697fed6177f806a2b2f")

        if response.has_key?('statistics')
          message.statistics = response['statistics']
        end

        if message.sent_from_buffer_at.blank? and response.has_key?('sent_at')
          message.sent_from_buffer_at = DateTime.strptime(response['sent_at'], "1318996912", '%s')
        end

        message.save
      end
    end
  end
end