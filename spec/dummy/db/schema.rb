# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20170409124162) do

  create_table "bank_accounts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "account_number"
    t.string   "iban",                  limit: 56
    t.string   "ifsc_swiftcode",        limit: 56
    t.string   "bank_name"
    t.string   "branch_name",           limit: 56
    t.string   "city",                  limit: 56
    t.integer  "country_id"
    t.integer  "bank_accountable_id"
    t.string   "bank_accountable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["bank_accountable_id", "bank_accountable_type"], name: "indx_bank_accountable_id_and_type", using: :btree
  end

  create_table "brands", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 512,                         null: false
    t.boolean  "featured",               default: false
    t.string   "status",     limit: 16,  default: "unpublished", null: false
    t.integer  "priority"
    t.datetime "created_at",                                     null: false
    t.datetime "updated_at",                                     null: false
    t.index ["status"], name: "index_brands_on_status", using: :btree
  end

  create_table "categories", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",          limit: 128,                         null: false
    t.string   "one_liner",     limit: 128
    t.integer  "parent_id"
    t.integer  "top_parent_id"
    t.string   "status",        limit: 16,  default: "unpublished", null: false
    t.boolean  "featured",                  default: false
    t.integer  "priority"
    t.datetime "created_at",                                        null: false
    t.datetime "updated_at",                                        null: false
    t.index ["parent_id"], name: "index_categories_on_parent_id", using: :btree
    t.index ["status"], name: "index_categories_on_status", using: :btree
    t.index ["top_parent_id"], name: "index_categories_on_top_parent_id", using: :btree
  end

  create_table "contacts", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "designation",      limit: 56
    t.string   "email",                       null: false
    t.string   "phone",            limit: 24
    t.string   "landline",         limit: 24
    t.string   "fax",              limit: 24
    t.integer  "contactable_id"
    t.string   "contactable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["contactable_id", "contactable_type"], name: "index_contacts_on_contactable_id_and_contactable_type", using: :btree
    t.index ["name"], name: "index_contacts_on_name", using: :btree
  end

  create_table "countries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 128
    t.string   "code",       limit: 16
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_countries_on_code", unique: true, using: :btree
  end

  create_table "documents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "document"
    t.string   "document_type"
    t.integer  "documentable_id"
    t.string   "documentable_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["documentable_id", "documentable_type"], name: "index_documents_on_documentable_id_and_documentable_type", using: :btree
  end

  create_table "exchange_rates", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "base_currency",    limit: 4
    t.string   "counter_currency", limit: 4
    t.decimal  "value",                      precision: 16, scale: 4
    t.datetime "effective_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "country_id"
    t.index ["base_currency", "counter_currency"], name: "index_exchange_rates_on_base_currency_and_counter_currency", using: :btree
  end

  create_table "features", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "status",     limit: 16, default: "unpublished", null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
  end

  create_table "images", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "image"
    t.string   "image_type"
    t.integer  "imageable_id"
    t.string   "imageable_type"
    t.datetime "created_at",     null: false
    t.datetime "updated_at",     null: false
    t.index ["imageable_id", "imageable_type"], name: "index_images_on_imageable_id_and_imageable_type", using: :btree
  end

  create_table "import_data", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "importable_id"
    t.string   "importable_type"
    t.string   "data_type"
    t.string   "status",          limit: 16, default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["data_type"], name: "index_import_data_on_data_type", using: :btree
    t.index ["importable_id", "importable_type"], name: "index_import_data_on_importable_id_and_importable_type", using: :btree
    t.index ["status"], name: "index_import_data_on_status", using: :btree
  end

  create_table "invoices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "invoice_number"
    t.datetime "invoice_date"
    t.string   "customer_name"
    t.string   "customer_address"
    t.string   "customer_phone"
    t.string   "customer_email"
    t.decimal  "discount",                         precision: 10
    t.decimal  "tax",                              precision: 10
    t.decimal  "gross_total_amount",               precision: 10
    t.decimal  "net_total_amount",                 precision: 10
    t.decimal  "adjustment",                       precision: 10
    t.text     "notes",              limit: 65535
    t.string   "payment_method",     limit: 16,                   default: "cash",  null: false
    t.decimal  "money_taken",                      precision: 10
    t.string   "cheque_number"
    t.string   "credit_card_number"
    t.string   "status",             limit: 16,                   default: "draft", null: false
    t.integer  "terminal_id"
    t.integer  "store_id"
    t.integer  "user_id"
    t.datetime "created_at",                                                        null: false
    t.datetime "updated_at",                                                        null: false
    t.index ["invoice_number"], name: "index_invoices_on_invoice_number", unique: true, using: :btree
    t.index ["store_id"], name: "index_invoices_on_store_id", using: :btree
    t.index ["terminal_id"], name: "index_invoices_on_terminal_id", using: :btree
    t.index ["user_id"], name: "index_invoices_on_user_id", using: :btree
  end

  create_table "line_items", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "product_id"
    t.integer  "quantity"
    t.decimal  "rate",                    precision: 10
    t.decimal  "discount",                precision: 10
    t.decimal  "tax",                     precision: 10
    t.decimal  "total_amount",            precision: 10
    t.integer  "invoice_id"
    t.string   "status",       limit: 16,                default: "draft", null: false
    t.datetime "created_at",                                               null: false
    t.datetime "updated_at",                                               null: false
    t.index ["invoice_id"], name: "index_line_items_on_invoice_id", using: :btree
    t.index ["product_id"], name: "index_line_items_on_product_id", using: :btree
  end

  create_table "permissions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "feature_id"
    t.boolean  "can_create", default: false
    t.boolean  "can_read",   default: true
    t.boolean  "can_update", default: false
    t.boolean  "can_delete", default: false
    t.datetime "created_at",                 null: false
    t.datetime "updated_at",                 null: false
    t.index ["feature_id"], name: "index_permissions_on_feature_id", using: :btree
    t.index ["user_id", "feature_id"], name: "index_permissions_on_user_id_and_feature_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_permissions_on_user_id", using: :btree
  end

  create_table "products", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",             limit: 128,                                                    null: false
    t.string   "one_liner"
    t.text     "description",      limit: 65535
    t.string   "ean_sku"
    t.string   "reference_number"
    t.integer  "brand_id"
    t.integer  "category_id"
    t.integer  "top_category_id"
    t.decimal  "purchased_price",                precision: 16, scale: 2
    t.decimal  "landed_price",                   precision: 16, scale: 2
    t.decimal  "selling_price",                  precision: 16, scale: 2
    t.decimal  "retail_price",                   precision: 16, scale: 2
    t.string   "status",           limit: 16,                             default: "unpublished", null: false
    t.boolean  "featured",                                                default: false
    t.datetime "created_at",                                                                      null: false
    t.datetime "updated_at",                                                                      null: false
    t.index ["brand_id"], name: "index_products_on_brand_id", using: :btree
    t.index ["category_id"], name: "index_products_on_category_id", using: :btree
    t.index ["status"], name: "index_products_on_status", using: :btree
    t.index ["top_category_id"], name: "index_products_on_top_category_id", using: :btree
  end

  create_table "regions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name",       limit: 128
    t.string   "code",       limit: 16
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_regions_on_code", unique: true, using: :btree
    t.index ["country_id"], name: "index_regions_on_country_id", using: :btree
    t.index ["name"], name: "index_regions_on_name", using: :btree
  end

  create_table "roles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles_users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_roles_users_on_role_id", using: :btree
    t.index ["user_id", "role_id"], name: "index_roles_users_on_user_id_and_role_id", unique: true, using: :btree
    t.index ["user_id"], name: "index_roles_users_on_user_id", using: :btree
  end

  create_table "stock_bundles", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.datetime "uploaded_date"
    t.integer  "store_id"
    t.integer  "supplier_id"
    t.integer  "uploader_id"
    t.string   "name"
    t.string   "file"
    t.string   "error_summary"
    t.string   "error_details"
    t.string   "error_file"
    t.string   "status",        limit: 16, default: "pending", null: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["store_id"], name: "index_stock_bundles_on_store_id", using: :btree
    t.index ["supplier_id"], name: "index_stock_bundles_on_supplier_id", using: :btree
    t.index ["uploader_id"], name: "index_stock_bundles_on_uploader_id", using: :btree
  end

  create_table "stock_entries", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer  "store_id"
    t.integer  "product_id"
    t.integer  "supplier_id"
    t.integer  "stock_bundle_id"
    t.integer  "invoice_id"
    t.integer  "quantity"
    t.string   "status",          limit: 16, default: "active", null: false
    t.datetime "created_at",                                    null: false
    t.datetime "updated_at",                                    null: false
    t.index ["invoice_id"], name: "index_stock_entries_on_invoice_id", using: :btree
    t.index ["product_id"], name: "index_stock_entries_on_product_id", using: :btree
    t.index ["stock_bundle_id"], name: "index_stock_entries_on_stock_bundle_id", using: :btree
    t.index ["store_id"], name: "index_stock_entries_on_store_id", using: :btree
    t.index ["supplier_id"], name: "index_stock_entries_on_supplier_id", using: :btree
  end

  create_table "stores", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "code",       limit: 24
    t.string   "store_type", limit: 24, default: "POS",    null: false
    t.string   "status",     limit: 16, default: "active", null: false
    t.integer  "region_id"
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_stores_on_code", unique: true, using: :btree
    t.index ["country_id"], name: "index_stores_on_country_id", using: :btree
    t.index ["name"], name: "index_stores_on_name", using: :btree
    t.index ["region_id"], name: "index_stores_on_region_id", using: :btree
  end

  create_table "suppliers", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "code",       limit: 24
    t.text     "address",    limit: 65535
    t.string   "city",       limit: 56
    t.integer  "country_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["code"], name: "index_suppliers_on_code", unique: true, using: :btree
    t.index ["country_id"], name: "index_suppliers_on_country_id", using: :btree
    t.index ["name"], name: "index_suppliers_on_name", using: :btree
  end

  create_table "terminals", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "code",       limit: 24
    t.string   "status",     limit: 16, default: "active", null: false
    t.integer  "store_id"
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.index ["code"], name: "index_terminals_on_code", unique: true, using: :btree
    t.index ["name"], name: "index_terminals_on_name", using: :btree
    t.index ["store_id"], name: "index_terminals_on_store_id", using: :btree
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string   "name"
    t.string   "username",               limit: 32,                     null: false
    t.string   "email",                                                 null: false
    t.string   "phone",                  limit: 24
    t.string   "designation",            limit: 56
    t.boolean  "super_admin",                       default: false
    t.string   "status",                 limit: 16, default: "pending", null: false
    t.string   "password_digest",                                       null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                     default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.integer  "failed_attempts",                   default: 0
    t.string   "unlock_token"
    t.datetime "locked_at"
    t.string   "auth_token"
    t.datetime "token_created_at"
    t.datetime "created_at",                                            null: false
    t.datetime "updated_at",                                            null: false
    t.index ["auth_token"], name: "index_users_on_auth_token", unique: true, using: :btree
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true, using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
    t.index ["unlock_token"], name: "index_users_on_unlock_token", unique: true, using: :btree
  end

end
