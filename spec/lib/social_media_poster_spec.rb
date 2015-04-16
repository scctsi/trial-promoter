require 'rails_helper'

RSpec.describe SocialMediaPoster do
  before do
    @social_media_poster = SocialMediaPoster.new
  end

  it 'gets a Buffer supplied profile id given a formatted Twitter account username (Format: @username)' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('@SoCalCTSI')

      expect(buffer_profile_id).to eq('53275ff6c441ced7264e4ca5')
    end
  end

  it 'gets a Buffer supplied profile id given a formatted Twitter account username (Format: @username) and ignores the case' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('@socalctsi')

      expect(buffer_profile_id).to eq('53275ff6c441ced7264e4ca5')
    end
  end

  it 'gets a Buffer supplied profile id given a Twitter account username (Format: username)' do
    VCR.use_cassette("social_media_poster/get_buffer_profile_id") do
      buffer_profile_id = @social_media_poster.get_buffer_profile_id('socalctsi')

      expect(buffer_profile_id).to eq('53275ff6c441ced7264e4ca5')
    end
  end

  # it 'publishes an update using Buffer' do
  #  allow(@publicist).to receive(:get_buffer_profile_ids).and_return(['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'])
  #  update = FactoryGirl.create(:update)
  #  body = {
  #      :text => update.text,
  #      :profile_ids => ['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'],
  #      :scheduled_at => nil,
  #      :access_token => "1/2852dbc6f3e36697fed6177f806a2b2f"
  #  }
  #  expect(Publicist).to receive(:post).with('https://api.bufferapp.com/1/updates/create.json', {:body => body})
  #
  #  @publicist.publish(update)
  # end

  #it 'gets an array of Buffer supplied profiles ids given an array of Twitter account usernames' do
  #  buffer_profile_ids = @publicist.get_buffer_profile_ids(['socalctsi', '@SoCalCTSI', '@socalctsi'])
  #
  #  expect(buffer_profile_ids).to eq(['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'])
  #end
  #
  #
  #it 'can publish an update using Buffer at a particular scheduled time' do
  #  allow(@publicist).to receive(:get_buffer_profile_ids).and_return(['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'])
  #  update = FactoryGirl.create(:update)
  #  update.scheduled_date = DateTime.parse('2000-01-01 00:00:00')
  #  body = {
  #      :text => update.text,
  #      :profile_ids => ['53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5', '53275ff6c441ced7264e4ca5'],
  #      :scheduled_at => DateTime.parse('2000-01-01 00:00:00'),
  #      :access_token => "1/2852dbc6f3e36697fed6177f806a2b2f"
  #  }
  #  expect(Publicist).to receive(:post).with('https://api.bufferapp.com/1/updates/create.json', {:body => body})
  #
  #  @publicist.publish(update)
  #end
end
