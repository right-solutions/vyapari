FactoryGirl.define do

	factory :supplier do
    name "Supplier Name"
    sequence(:code){|n| "SUPCD#{n}" }
    address "Some Address, House Number"
    city "City"
		country
  end

end
