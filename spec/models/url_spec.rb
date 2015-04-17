require 'rails_helper'

RSpec.describe Url do
  it { is_expected.to validate_presence_of :value }

  it 'always sets a clean value using PostRank::URI.clean' do
    allow(PostRank::URI).to receive(:clean).and_return('cleaned_url')
    url = Url.new

    url.value = 'http://www.example.com:80/bar.html'

    expect(url.value).to eq('cleaned_url')
  end
end
