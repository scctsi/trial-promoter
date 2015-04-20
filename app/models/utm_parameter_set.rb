class UtmParameterSet < ActiveRecord::Base
  belongs_to :url

  validates :source, presence: true
  validates :source, format: { with: /\A[A-Za-z0-9\-]+\z/ }
  validates :medium, presence: true
  validates :medium, format: { with: /\A[A-Za-z0-9\-]+\z/ }
  validates :campaign, presence: true
  validates :campaign, format: { with: /\A[A-Za-z0-9\-]+\z/ }

  def value=(value)
    # TODO: Unit test that nil values are set correctly
    if value == nil
      write_attribute(:value, nil)
      return
    end

    write_attribute(:value, PostRank::URI.clean(value))
  end

  def tracking_fragment
    "utm_source=#{source}&utm_medium=#{medium}&utm_campaign=#{campaign}"
  end
end