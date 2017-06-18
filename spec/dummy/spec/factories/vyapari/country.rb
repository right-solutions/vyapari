FactoryGirl.define do

	factory :country do
    name "Country Name"
    sequence(:code){|n| "CTRCD#{n}" }
  end

end
