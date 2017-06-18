FactoryGirl.define do

  factory :store do

    name "Store Name"
    sequence(:code){|n| "STRCD#{n}" }
    
    region
    country

    status "active"
    store_type Store::POS_STORE
    
  end

  # POS factories

  factory :active_pos_store, parent: :store do
    status "active"
    store_type Store::POS_STORE
  end

  factory :inactive_pos_store, parent: :store do
    status "inactive"
    store_type Store::POS_STORE
  end

  factory :closed_pos_store, parent: :store do
    status "closed"
    store_type Store::POS_STORE
  end

  # Warehouse factories

  factory :active_warehouse, parent: :store do
    status "active"
    store_type Store::WAREHOUSE
  end

  factory :inactive_warehouse, parent: :store do
    status "inactive"
    store_type Store::WAREHOUSE
  end

  factory :closed_warehouse, parent: :store do
    status "closed"
    store_type Store::WAREHOUSE
  end


  # E-Commerce Store factories

  factory :active_ecommerce_store, parent: :store do
    status "active"
    store_type Store::ECOMMERCE_STORE
  end

  factory :inactive_ecommerce_store, parent: :store do
    status "inactive"
    store_type Store::ECOMMERCE_STORE
  end

  factory :closed_ecommerce_store, parent: :store do
    status "closed"
    store_type Store::ECOMMERCE_STORE
  end

end

