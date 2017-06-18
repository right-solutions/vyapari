FactoryGirl.define do

  factory :contact do
    name "Contact Name"
    designation "Designation"
    email "email@domain.com"
    phone "+1234567890"
    landline "+1234567890"
    fax "+1234567890"
  end

  factory :invoice_contact do
	   association :contactable, factory: :invoice
	end

end
