FactoryGirl.define do

  factory :exchange_rate do
    base_currency "CUR1"
    counter_currency "CUR2"
    value 12.34
    effective_date Date.parse('01/01/2001')
  end

end
