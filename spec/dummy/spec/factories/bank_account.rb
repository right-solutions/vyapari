FactoryGirl.define do

  factory :bank_account do

    account_number "81273192379182379"
    iban "1892639816283912"
    ifsc_swiftcode "179263791623123"
    bank_name "Bank Name of the Country"
    branch_name "Branch Name"
    city "City"
    country

  end

  factory :invoice_bank_account do
    association :bank_accountable, factory: :invoice
	end

end
