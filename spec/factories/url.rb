FactoryGirl.define do
  factory :url do
    value 'http://www.sc-ctsi.org'
  end

  factory :url_with_utm_parameter_set, class: Url do
    value 'http://www.sc-ctsi.org'
    utm_parameter_set
  end
end