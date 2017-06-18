FactoryGirl.define do

  factory :product do

    sequence(:name){|n| "Product-#{n}" }
    one_liner "One Liner for Product"
    description "Description"

    sequence(:ean_sku){|n| "#{Time.now.to_i}{n}" }
    reference_number "Ref No. 1020012"

    brand
    category

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
