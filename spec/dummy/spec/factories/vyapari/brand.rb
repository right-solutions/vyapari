FactoryGirl.define do

  factory :brand do
    sequence(:name){|n| "Brand-#{n}" }
    priority 1000
  end

  factory :published_brand, parent: :brand do
    status "published"
  end

  factory :unpublished_brand, parent: :brand do
    status "unpublished"
  end

  factory :removed_brand, parent: :brand do
    status "removed"
  end

  factory :featured_brand, parent: :published_brand do
    featured true
  end

  factory :unfeatured_brand, parent: :published_brand do
    featured false
  end

end
