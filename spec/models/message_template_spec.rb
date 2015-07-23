require 'rails_helper'

RSpec.describe MessageTemplate do
  it { is_expected.to validate_presence_of :initial_id }
  it { is_expected.to validate_presence_of :content }
  it { is_expected.to validate_presence_of :platform }
  it { is_expected.to validate_presence_of :message_type }

  it { is_expected.to have_many :messages }

  # it { is_expected.to validate_presence_of :content }
  # it { is_expected.to belong_to :platform }
  # it { is_expected.to validate_presence_of}
  #
  # it 'is taggable on categories' do
  #   message_template = MessageTemplate.new(content: 'Content')
  #
  #   message_template.category_list = "general, mention researcher"
  #   message_template.save
  #   message_template.reload
  #
  #   expect(message_template.categories.count).to eq(2)
  # end
  #
  # it 'is taggable on platforms' do
  #   message_template = MessageTemplate.new(content: 'Content')
  #
  #   message_template.platform_list = "twitter, facebook"
  #   message_template.save
  #   message_template.reload
  #
  #   expect(message_template.platforms.count).to eq(2)
  # end
end
