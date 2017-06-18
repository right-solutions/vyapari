FactoryGirl.define do

  factory :line_item do
    product
    invoice

    quantity 2

    rate 0.00
    discount 0.00
    tax 0.00
    total_amount 0.00
  end

  factory :draft_line_item, parent: :line_item do
    status "draft"
  end

  factory :sold_line_item, parent: :line_item do
    status "sold"
  end

  factory :damaged_line_item, parent: :line_item do
    status "damaged"
  end

  factory :returned_line_item, parent: :line_item do
    status "returned"
  end

  factory :cancelled_line_item, parent: :line_item do
    status "cancelled"
  end
  
end
