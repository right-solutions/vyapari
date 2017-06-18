FactoryGirl.define do

  sequence(:invoice_number) {|n| "INV-TERMNO-#{n}" }
  sequence(:customer_email) {|n| "customer.#{n}@domain.com" }

  factory :invoice do

    invoice_number
    invoice_date { Date.today }

    customer_name "Customer name"
    customer_address "Customer Address, Stree, City, Country"
    customer_phone "123-456-7890"
    customer_email 

    discount 0.0
    tax 0.0
    gross_total_amount 0.0
    net_total_amount 0.0
    adjustment 0.0
    money_taken 0.0

    notes "Lorem ipsum dolor sit amet, mel in affert tincidunt, ut cum melius laoreet definiebas. Sea rationibus deseruisse at, nec ei magna impedit conceptam. Id idque dolorem detraxit sea, no vim augue democritum honestatis, per in suscipit nominati reformidans. Ex sit nostrum cotidieque theophrastus. Sit eu regione abhorreant, in nulla expetendis eum. Ne soleat fabulas epicurei duo, id alii populo vis."
    
    store
    terminal
    user
    
  end

  # Draft Invoices

  factory :draft_cash_invoice, parent: :draft_invoice do
    status "draft"
    payment_method "cash"
  end

  factory :draft_credit_card_invoice, parent: :draft_invoice do
    status "draft"
    payment_method "credit_card"
    credit_card_number "1234123412341234"
  end

  factory :draft_credit_invoice, parent: :draft_invoice do
    status "draft"
    payment_method "credit"
  end

  factory :draft_cheque_invoice, parent: :draft_invoice do
    status "draft"
    payment_method "cheque"
    cheque_number "198263918623"
  end

  # Active Invoices

  factory :active_cash_invoice, parent: :active_invoice do
    status "active"
    payment_method "cash"
  end

  factory :active_credit_card_invoice, parent: :active_invoice do
    status "active"
    payment_method "credit_card"
    credit_card_number "1234123412341234"
  end

  factory :active_credit_invoice, parent: :active_invoice do
    status "active"
    payment_method "credit"
  end

  factory :active_cheque_invoice, parent: :active_invoice do
    status "active"
    payment_method "cheque"
    cheque_number "198263918623"
  end

  # Cancelled Invoices

  factory :cancelled_cash_invoice, parent: :cancelled_invoice do
    status "cancelled"
    payment_method "cash"
  end

  factory :cancelled_credit_card_invoice, parent: :cancelled_invoice do
    status "cancelled"
    payment_method "credit_card"
    credit_card_number "1234123412341234"
  end

  factory :cancelled_credit_invoice, parent: :cancelled_invoice do
    status "cancelled"
    payment_method "credit"
  end

  factory :cancelled_cheque_invoice, parent: :cancelled_invoice do
    status "cancelled"
    payment_method "cheque"
    cheque_number "198263918623"
  end

  factory :invoice_with_customer, parent: :draft_cash_invoice do 
     after(:create) do |invoice| 
       invoice.contact = create(:invoice_contact, contactable: invoice)
     end
  end
  
end
