# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.0].define(version: 2023_04_18_045818) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "accounting_codes", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "country_id", null: false
    t.string "first_line"
    t.string "second_line"
    t.string "city"
    t.string "state"
    t.string "postcode"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["country_id"], name: "index_addresses_on_country_id"
  end

  create_table "category_tags", force: :cascade do |t|
    t.string "name", null: false
    t.boolean "enabled", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "category_tags_products", id: false, force: :cascade do |t|
    t.bigint "category_tag_id", null: false
    t.bigint "product_id", null: false
    t.index ["category_tag_id"], name: "index_category_tags_products_on_category_tag_id"
    t.index ["product_id"], name: "index_category_tags_products_on_product_id"
  end

  create_table "countries", force: :cascade do |t|
    t.string "country"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.string "email_address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.integer "variant_id"
    t.integer "product_id"
    t.integer "quantity"
    t.integer "stock_adjustment_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
    t.index ["stock_adjustment_id"], name: "index_order_items_on_stock_adjustment_id"
    t.index ["variant_id"], name: "index_order_items_on_variant_id"
  end

  create_table "orders", force: :cascade do |t|
    t.integer "customer_id"
    t.integer "state"
    t.integer "payment_method"
    t.string "payment_other_method"
    t.integer "payment_amount"
    t.string "adjustments"
    t.boolean "delivery"
    t.string "notes"
    t.string "first_name"
    t.string "last_name"
    t.string "email_address"
    t.string "phone_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_orders_on_customer_id"
  end

  create_table "product_attribute_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_attributes", force: :cascade do |t|
    t.string "name"
    t.string "value"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_attributes_variants", id: false, force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.bigint "product_attribute_id", null: false
    t.index ["product_attribute_id"], name: "index_product_attributes_variants_on_product_attribute_id"
    t.index ["variant_id"], name: "index_product_attributes_variants_on_variant_id"
  end

  create_table "products", force: :cascade do |t|
    t.bigint "supplier_id", null: false
    t.bigint "accounting_code_id", null: false
    t.string "title"
    t.text "description"
    t.text "notes"
    t.string "sku_code"
    t.string "barcode"
    t.boolean "publish"
    t.string "markup"
    t.integer "cost_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "retail_price"
    t.integer "price_calc_method"
    t.index ["accounting_code_id"], name: "index_products_on_accounting_code_id"
    t.index ["supplier_id"], name: "index_products_on_supplier_id"
  end

  create_table "receipts", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.string "email_address"
    t.string "item_one_name"
    t.string "item_one_price_minus_tax"
    t.string "item_two_name"
    t.string "item_two_price_minus_tax"
    t.string "item_three_name"
    t.string "item_three_price_minus_tax"
    t.string "item_four_name"
    t.string "item_four_price_minus_tax"
    t.string "item_five_name"
    t.string "item_five_price_minus_tax"
    t.string "item_six_name"
    t.string "item_six_price_minus_tax"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_receipts_on_order_id"
  end

  create_table "stock_adjustments", force: :cascade do |t|
    t.bigint "variant_id", null: false
    t.integer "quantity"
    t.integer "adjustment_type", null: false
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["variant_id"], name: "index_stock_adjustments_on_variant_id"
  end

  create_table "suppliers", force: :cascade do |t|
    t.bigint "address_id", null: false
    t.string "name"
    t.string "email"
    t.json "phone"
    t.text "notes"
    t.boolean "sales_tax_registered"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "tax_rate_id"
    t.bigint "#<ActiveRecord::ConnectionAdapters::PostgreSQL::TableDefinition"
    t.string "bank_acount_name"
    t.string "bank_acount_number"
    t.string "bank_bsb"
    t.string "bank_name"
    t.index ["address_id"], name: "index_suppliers_on_address_id"
  end

  create_table "tax_rates", force: :cascade do |t|
    t.string "rate"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "variants", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.string "sku_code"
    t.string "barcode"
    t.string "markup"
    t.integer "cost_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["product_id"], name: "index_variants_on_product_id"
  end

  create_table "views", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_views_on_email", unique: true
    t.index ["reset_password_token"], name: "index_views_on_reset_password_token", unique: true
  end

  add_foreign_key "addresses", "countries"
  add_foreign_key "order_items", "orders"
  add_foreign_key "products", "accounting_codes"
  add_foreign_key "products", "suppliers"
  add_foreign_key "receipts", "orders"
  add_foreign_key "stock_adjustments", "variants"
  add_foreign_key "suppliers", "addresses"
  add_foreign_key "variants", "products"
end
