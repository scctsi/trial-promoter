require 'rails_helper'

RSpec.describe UtmParameterSet do
  it { is_expected.to validate_presence_of :source }
  it { is_expected.to validate_presence_of :medium }
  it { is_expected.to validate_presence_of :campaign }
end
