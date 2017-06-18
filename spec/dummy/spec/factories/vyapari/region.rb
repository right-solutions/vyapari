FactoryGirl.define do

	factory :region do
    name "Region Name"
    sequence(:code){|n| "RGNCD#{n}" }

    country
  end

end
