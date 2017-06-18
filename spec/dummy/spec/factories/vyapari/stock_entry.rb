FactoryGirl.define do

	factory :stock_entry do

		store
    product
    supplier
    # stock_bundle
    invoice

    quantity 10

    purchased_price 100.0
    landed_cost 32.34
    miscellaneous_cost 6.52
    cost_price 138.86
    discount 2.0 # percentage(%)
    wholesale_price 173.575 # 25% profit added
    retail_price 222.176 # 60% profit added

  end

  factory :active_stock_entry, parent: :stock_entry do
    status "active"
  end

  factory :sold_stock_entry, parent: :stock_entry do
    status "sold"
  end

  factory :damaged_stock_entry, parent: :stock_entry do
    status "damaged"
  end

  factory :received_stock_entry, parent: :stock_entry do
    status "received"
  end

  factory :returned_stock_entry, parent: :stock_entry do
    status "returned"
  end

  factory :reserved_stock_entry, parent: :stock_entry do
    status "reserved"
  end

  factory :pending_stock_entry, parent: :stock_entry do
    status "pending"
  end

end
