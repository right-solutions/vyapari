FactoryGirl.define do

  factory :category do
    name "Category Name"
    one_liner "One Liner for Category"

    featured false
    priority 1000

    status "unpublished"

    association :parent, factory: :category
  end

  factory :published_category, parent: :category do
    status "published"
  end

  factory :unpublished_category, parent: :category do
    status "unpublished"
  end

  factory :removed_category, parent: :category do
    status "removed"
  end

  factory :featured_category, parent: :published_category do
    featured true
  end

  factory :unfeatured_category, parent: :published_category do
    featured false
  end

end
