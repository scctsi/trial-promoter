require 'rails_helper'

describe Message do
  it { is_expected.to validate_presence_of(:content) }
  it { is_expected.to validate_presence_of(:campaign) }
  it { is_expected.to validate_presence_of(:medium) }

  # Source - Platform
  # Medium - Ad, Organic
  # Campaign - Trial Promoter Staging or Trial Promoter

  it { is_expected.to belong_to :clinical_trial }
  it { is_expected.to belong_to :message_template }
end
