require 'rails_helper'

describe ClinicalTrial do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:pi_name) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:nct_id) }
  it { is_expected.to validate_presence_of(:initial_database_id) }
end
