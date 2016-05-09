# encoding: UTF-8
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

ActiveRecord::Schema.define(version: 20160509095910) do

  create_table "addresses", force: :cascade do |t|
    t.integer  "shopper_id",    limit: 4
    t.string   "area",          limit: 255
    t.string   "detail",        limit: 255
    t.string   "lat",           limit: 255
    t.string   "lng",           limit: 255
    t.string   "receive_name",  limit: 255
    t.string   "receive_phone", limit: 255
    t.boolean  "is_default",                default: false, null: false
    t.integer  "status",        limit: 1,   default: 0,     null: false
    t.datetime "created_at",                                null: false
    t.datetime "updated_at",                                null: false
  end

  add_index "addresses", ["receive_name"], name: "index_addresses_on_receive_name", using: :btree
  add_index "addresses", ["receive_phone"], name: "index_addresses_on_receive_phone", using: :btree
  add_index "addresses", ["shopper_id"], name: "index_addresses_on_shopper_id", using: :btree

  create_table "adverts", force: :cascade do |t|
    t.integer  "shop_id",         limit: 4
    t.integer  "shop_product_id", limit: 4
    t.string   "key",             limit: 255
    t.integer  "status",          limit: 1,   default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "adverts", ["shop_id"], name: "index_adverts_on_shop_id", using: :btree
  add_index "adverts", ["shop_product_id"], name: "index_adverts_on_shop_product_id", using: :btree

  create_table "carts", force: :cascade do |t|
    t.integer  "shop_id",         limit: 4
    t.integer  "shopper_id",      limit: 4
    t.integer  "shop_product_id", limit: 4
    t.integer  "product_num",     limit: 4
    t.integer  "status",          limit: 1, default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "carts", ["shop_id"], name: "index_carts_on_shop_id", using: :btree
  add_index "carts", ["shop_product_id"], name: "index_carts_on_shop_product_id", using: :btree
  add_index "carts", ["shopper_id"], name: "index_carts_on_shopper_id", using: :btree

  create_table "categories", force: :cascade do |t|
    t.integer  "shop_id",      limit: 4
    t.string   "name",         limit: 255
    t.string   "name_as",      limit: 255
    t.string   "key",          limit: 255
    t.string   "logo_key",     limit: 255
    t.integer  "sort",         limit: 4,   default: 1,     null: false
    t.boolean  "is_app_index",             default: false, null: false
    t.integer  "status",       limit: 1,   default: 0,     null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "categories", ["name"], name: "index_categories_on_name", using: :btree
  add_index "categories", ["shop_id"], name: "index_categories_on_shop_id", using: :btree

  create_table "detail_categories", force: :cascade do |t|
    t.integer  "shop_id",         limit: 4
    t.integer  "category_id",     limit: 4
    t.integer  "sub_category_id", limit: 4
    t.string   "name",            limit: 255
    t.string   "key",             limit: 255
    t.integer  "sort",            limit: 4,   default: 1, null: false
    t.integer  "status",          limit: 1,   default: 0, null: false
    t.datetime "created_at",                              null: false
    t.datetime "updated_at",                              null: false
  end

  add_index "detail_categories", ["category_id"], name: "index_detail_categories_on_category_id", using: :btree
  add_index "detail_categories", ["name"], name: "index_detail_categories_on_name", using: :btree
  add_index "detail_categories", ["shop_id"], name: "index_detail_categories_on_shop_id", using: :btree
  add_index "detail_categories", ["sub_category_id"], name: "index_detail_categories_on_sub_category_id", using: :btree

  create_table "favorites", force: :cascade do |t|
    t.integer  "shop_id",         limit: 4
    t.integer  "shopper_id",      limit: 4
    t.integer  "shop_product_id", limit: 4
    t.integer  "status",          limit: 1, default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "favorites", ["shop_id"], name: "index_favorites_on_shop_id", using: :btree
  add_index "favorites", ["shop_product_id"], name: "index_favorites_on_shop_product_id", using: :btree
  add_index "favorites", ["shopper_id"], name: "index_favorites_on_shopper_id", using: :btree

  create_table "images", force: :cascade do |t|
    t.string   "key",            limit: 255
    t.integer  "imageable_id",   limit: 4
    t.string   "imageable_type", limit: 255
    t.integer  "sort",           limit: 4,   default: 1, null: false
    t.integer  "status",         limit: 1,   default: 0, null: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  add_index "images", ["imageable_id", "imageable_type"], name: "imageable_index", using: :btree

  create_table "messages", force: :cascade do |t|
    t.integer  "shopper_id",       limit: 4
    t.integer  "shop_id",          limit: 4
    t.integer  "messageable_id",   limit: 4
    t.string   "messageable_type", limit: 255
    t.string   "title",            limit: 255
    t.string   "info",             limit: 255
    t.integer  "is_new",           limit: 1,   default: 0, null: false
    t.integer  "status",           limit: 1,   default: 0, null: false
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
  end

  add_index "messages", ["messageable_id", "messageable_type"], name: "messageable_index", using: :btree
  add_index "messages", ["shop_id"], name: "index_messages_on_shop_id", using: :btree
  add_index "messages", ["shopper_id"], name: "index_messages_on_shopper_id", using: :btree

  create_table "orders", force: :cascade do |t|
    t.integer  "shopper_id",    limit: 4
    t.integer  "shop_id",       limit: 4
    t.integer  "address_id",    limit: 4
    t.string   "receive_name",  limit: 255
    t.string   "receive_phone", limit: 255
    t.string   "area",          limit: 255
    t.string   "detail",        limit: 255
    t.string   "order_no",      limit: 255
    t.integer  "order_type",    limit: 1,                                                null: false
    t.string   "trade_no",      limit: 255
    t.decimal  "total_price",               precision: 12, scale: 2, default: 0.0
    t.string   "state",         limit: 255,                          default: "opening"
    t.integer  "status",        limit: 1,                            default: 0,         null: false
    t.datetime "delivery_at"
    t.datetime "complete_at"
    t.datetime "expiration_at"
    t.datetime "created_at",                                                             null: false
    t.datetime "updated_at",                                                             null: false
  end

  add_index "orders", ["address_id"], name: "index_orders_on_address_id", using: :btree
  add_index "orders", ["order_no"], name: "index_orders_on_order_no", using: :btree
  add_index "orders", ["shop_id"], name: "index_orders_on_shop_id", using: :btree
  add_index "orders", ["shopper_id"], name: "index_orders_on_shopper_id", using: :btree
  add_index "orders", ["state"], name: "index_orders_on_state", using: :btree
  add_index "orders", ["trade_no"], name: "index_orders_on_trade_no", using: :btree

  create_table "orders_shop_products", force: :cascade do |t|
    t.integer  "order_id",        limit: 4
    t.integer  "shop_product_id", limit: 4
    t.integer  "product_num",     limit: 4
    t.decimal  "product_price",             precision: 12, scale: 2, default: 0.0
    t.integer  "status",          limit: 1,                          default: 0,   null: false
    t.datetime "created_at",                                                       null: false
    t.datetime "updated_at",                                                       null: false
  end

  add_index "orders_shop_products", ["order_id"], name: "index_orders_shop_products_on_order_id", using: :btree
  add_index "orders_shop_products", ["shop_product_id"], name: "index_orders_shop_products_on_shop_product_id", using: :btree

  create_table "products", force: :cascade do |t|
    t.integer  "category_id",        limit: 4
    t.integer  "sub_category_id",    limit: 4
    t.integer  "detail_category_id", limit: 4
    t.integer  "unit_id",            limit: 4
    t.string   "name",               limit: 255
    t.decimal  "price",                          precision: 12, scale: 2, default: 0.0
    t.decimal  "old_price",                      precision: 12, scale: 2, default: 0.0
    t.string   "key",                limit: 255
    t.string   "desc",               limit: 255
    t.string   "info",               limit: 255
    t.string   "spec",               limit: 255
    t.integer  "sort",               limit: 4,                            default: 1,   null: false
    t.integer  "status",             limit: 1,                            default: 0,   null: false
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
  end

  add_index "products", ["category_id"], name: "index_products_on_category_id", using: :btree
  add_index "products", ["detail_category_id"], name: "index_products_on_detail_category_id", using: :btree
  add_index "products", ["name"], name: "index_products_on_name", using: :btree
  add_index "products", ["sub_category_id"], name: "index_products_on_sub_category_id", using: :btree
  add_index "products", ["unit_id"], name: "index_products_on_unit_id", using: :btree

  create_table "shop_models", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "status",     limit: 1,   default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "shop_models", ["name"], name: "index_shop_models_on_name", using: :btree

  create_table "shop_products", force: :cascade do |t|
    t.integer  "shop_id",            limit: 4
    t.integer  "product_id",         limit: 4
    t.integer  "category_id",        limit: 4
    t.integer  "sub_category_id",    limit: 4
    t.integer  "detail_category_id", limit: 4
    t.integer  "unit_id",            limit: 4
    t.string   "name",               limit: 255
    t.decimal  "price",                          precision: 12, scale: 2, default: 0.0
    t.decimal  "old_price",                      precision: 12, scale: 2, default: 0.0
    t.integer  "stock_volume",       limit: 4
    t.integer  "sales_volume",       limit: 4
    t.string   "key",                limit: 255
    t.string   "desc",               limit: 255
    t.string   "info",               limit: 255
    t.string   "spec",               limit: 255
    t.integer  "sort",               limit: 4,                            default: 1,     null: false
    t.boolean  "is_app_index",                                            default: false, null: false
    t.integer  "status",             limit: 1,                            default: 0,     null: false
    t.datetime "created_at",                                                              null: false
    t.datetime "updated_at",                                                              null: false
  end

  add_index "shop_products", ["category_id"], name: "index_shop_products_on_category_id", using: :btree
  add_index "shop_products", ["detail_category_id"], name: "index_shop_products_on_detail_category_id", using: :btree
  add_index "shop_products", ["name"], name: "index_shop_products_on_name", using: :btree
  add_index "shop_products", ["product_id"], name: "index_shop_products_on_product_id", using: :btree
  add_index "shop_products", ["shop_id"], name: "index_shop_products_on_shop_id", using: :btree
  add_index "shop_products", ["sub_category_id"], name: "index_shop_products_on_sub_category_id", using: :btree
  add_index "shop_products", ["unit_id"], name: "index_shop_products_on_unit_id", using: :btree

  create_table "shoppers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.string   "phone",      limit: 255
    t.string   "token",      limit: 255
    t.string   "key",        limit: 255
    t.integer  "level",      limit: 1,   default: 0, null: false
    t.string   "client_id",  limit: 255
    t.integer  "status",     limit: 1,   default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "shoppers", ["name"], name: "index_shoppers_on_name", using: :btree
  add_index "shoppers", ["phone"], name: "index_shoppers_on_phone", using: :btree
  add_index "shoppers", ["token"], name: "index_shoppers_on_token", using: :btree

  create_table "shops", force: :cascade do |t|
    t.integer  "shop_model_id", limit: 4
    t.string   "name",          limit: 255
    t.string   "address",       limit: 255
    t.string   "lat",           limit: 255
    t.string   "lng",           limit: 255
    t.string   "tel",           limit: 255
    t.string   "phone",         limit: 255
    t.string   "director",      limit: 255
    t.integer  "status",        limit: 1,   default: 0, null: false
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
  end

  add_index "shops", ["director"], name: "index_shops_on_director", using: :btree
  add_index "shops", ["name"], name: "index_shops_on_name", using: :btree
  add_index "shops", ["phone"], name: "index_shops_on_phone", using: :btree

  create_table "sub_categories", force: :cascade do |t|
    t.integer  "shop_id",     limit: 4
    t.integer  "category_id", limit: 4
    t.string   "name",        limit: 255
    t.integer  "sort",        limit: 4,   default: 1, null: false
    t.integer  "status",      limit: 1,   default: 0, null: false
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  add_index "sub_categories", ["category_id"], name: "index_sub_categories_on_category_id", using: :btree
  add_index "sub_categories", ["name"], name: "index_sub_categories_on_name", using: :btree
  add_index "sub_categories", ["shop_id"], name: "index_sub_categories_on_shop_id", using: :btree

  create_table "top_searches", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "status",     limit: 1,   default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "top_searches", ["name"], name: "index_top_searches_on_name", using: :btree

  create_table "units", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.integer  "status",     limit: 1,   default: 0, null: false
    t.datetime "created_at",                         null: false
    t.datetime "updated_at",                         null: false
  end

  add_index "units", ["name"], name: "index_units_on_name", using: :btree

end
