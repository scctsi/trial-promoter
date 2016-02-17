# match_tp_urls.rb

require 'open-uri'
require 'rest_client'
require 'nokogiri'

class MatchTpUrls

  def self.match

    # Matching Trial Promoter URLs

    puts "\nMatching Trial Promoter URLs\n"

    organic_messages = 'http://tp.sc-ctsi.org/organic_messages'
    paid_messages = 'http://tp.sc-ctsi.org/paid_messages'

    #tp_url = organic_messages
    tp_url = paid_messages

    begin
      exists = RestClient.head(tp_url).code == 200
    rescue RestClient::Exception => error
      exists = (error.http_code != 404)
    rescue Timeout::Error
      puts "Timeout::Error: #{$!}\n"
      Rails.logger.info "Timeout::Error: #{$!}\n"
    rescue
      puts "Connection failed: #{$!}\n"
      Rails.logger.info "Connection failed: #{$!}\n"
    end

    if exists

      page = Nokogiri::HTML(open(tp_url))

      rows = page.css('.ui.table tr')

      index = 1
      rows.each do |row|

        if row.xpath("/html/body/div[3]/table/tbody/tr[#{index}]/td[6]/a").text.length > 1
          puts index

          bitly = row.xpath("/html/body/div[3]/table/tbody/tr[#{index}]/td[2]").text.to_s.scan(/http:\/\/bit.ly\/\w{5,8}/).first


          begin
            bitly_found = RestClient.head(bitly).code == 200
          rescue RestClient::Exception => error
            bitly_found = (error.http_code != 404)
          rescue Timeout::Error
            puts "Timeout::Error: #{$!}\n"
            Rails.logger.info "Timeout::Error: #{$!}\n"
          rescue
            puts "Connection failed: #{$!}\n"
            Rails.logger.info "Connection failed: #{$!}\n"
          end

          if bitly_found
            puts "bit.ly found: #{bitly}"
            res = Net::HTTP.get_response(URI(bitly))
            bitly_url = res['location'].to_s.split('/?').first.strip
            puts "URL from bit.ly: #{bitly_url}"
          end

          tp_url = row.xpath("/html/body/div[3]/table/tbody/tr[#{index}]/td[6]/a")[0]['href'].to_s.strip

          puts tp_url

          if bitly_url == tp_url

            puts 'bitly url is correct'

          else
            puts 'bitly url is NOT correct **********************'
          end
          index += 1
          puts "\n\n"
        else
          next
        end
      end
    end
  end
end
