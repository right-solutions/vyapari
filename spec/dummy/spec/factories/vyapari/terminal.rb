FactoryGirl.define do

  factory :terminal do

    name "Terminal Name"
    sequence(:code){|n| "TRMNL#{n}" }

    store

  end

  factory :active_terminal, parent: :terminal do
    status "active"
  end

  factory :inactive_terminal, parent: :terminal do
    status "inactive"
  end

  factory :closed_terminal, parent: :terminal do
    status "closed"
  end

end
