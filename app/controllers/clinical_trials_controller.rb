class ClinicalTrialsController < ApplicationController
  def index
    @clinical_trials = ClinicalTrial.all
  end
end
