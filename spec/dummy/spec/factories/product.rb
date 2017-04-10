FactoryGirl.define do

  sequence(:product_name) {|n| "Product-#{n}" }
  sequence(:ean_sku) {|n| "#{Time.now.to_i}{n}" }
	
  factory :product do

    name product_name
    one_liner "One Liner for Product"
    description "Description"

    ean_sku 
    reference_number "Ref No. 1020012"

    brand
    category

		purchased_price 100.0
		landed_price 110.0
		selling_price 160.0
		retail_price 220.0

  end

  factory :published_product, parent: :product do
    status "published"
  end

  factory :unpublished_product, parent: :product do
    status "unpublished"
  end

  factory :removed_product, parent: :product do
    status "removed"
  end

  factory :featured_product, parent: :published_product do
    featured true
  end

  factory :unfeatured_product, parent: :published_product do
    featured false
  end
  
end
