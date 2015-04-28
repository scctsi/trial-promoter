require 'rails_helper'

describe Platform do
  it { is_expected.to validate_presence_of(:name) }
  it { is_expected.to validate_presence_of(:medium) }

  it { is_expected.to have_many :message_templates }
end
