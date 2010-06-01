# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20100601021244) do

  create_table "addresses", :force => true do |t|
    t.string   "name"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "country"
    t.float    "lat"
    t.float    "lng"
    t.string   "geocode_precision"
    t.boolean  "public"
    t.boolean  "hidden"
    t.string   "addressable_type"
    t.integer  "addressable_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "addresses", ["addressable_id", "addressable_type"], :name => "index_addresses_on_addressable_id_and_addressable_type"

  create_table "affiliates", :force => true do |t|
    t.string   "name"
    t.string   "full_name"
    t.string   "logo_path"
    t.integer  "admin_role_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "affiliations", :force => true do |t|
    t.integer  "location_id"
    t.integer  "affiliate_id"
    t.date     "expires"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "contact_name"
    t.string   "contact_address"
    t.string   "contact_city"
    t.string   "contact_state"
    t.string   "contact_zip"
    t.string   "contact_telephone"
    t.string   "contact_email"
    t.string   "foreign_key"
  end

  add_index "affiliations", ["affiliate_id", "foreign_key"], :name => "index_affiliations_on_affiliate_id_and_foreign_key"

  create_table "clubs", :force => true do |t|
    t.string   "contacts"
    t.string   "description"
    t.string   "foreign_key"
    t.boolean  "hidden"
    t.string   "hours"
    t.string   "name"
    t.string   "slug"
    t.string   "source_id"
    t.string   "url"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.integer  "user_id"
    t.string   "street_address"
    t.string   "city"
    t.string   "state"
    t.string   "zip_code"
    t.string   "hours"
    t.decimal  "lat",               :precision => 15, :scale => 10
    t.decimal  "lng",               :precision => 15, :scale => 10
    t.string   "url"
    t.string   "description"
    t.text     "contacts"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "slug"
    t.string   "country"
    t.string   "geocode_precision"
    t.boolean  "hidden"
    t.integer  "source_id"
    t.string   "foreign_key"
  end

  add_index "locations", ["slug"], :name => "index_locations_on_slug", :unique => true

  create_table "messages", :force => true do |t|
    t.integer  "sender_id"
    t.integer  "recipient_id"
    t.string   "subject"
    t.string   "body"
    t.boolean  "read"
    t.integer  "message_responded_to_id"
    t.integer  "thread_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id"
  end

  create_table "slug_redirects", :force => true do |t|
    t.string   "slug"
    t.integer  "location_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "slug_redirects", ["slug"], :name => "index_slug_redirects_on_slug", :unique => true

  create_table "sources", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "user_roles", :force => true do |t|
    t.integer  "user_id"
    t.integer  "role_id"
    t.integer  "granting_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "login",                                                  :null => false
    t.string   "email",                                                  :null => false
    t.string   "crypted_password",                                       :null => false
    t.string   "salt",                                                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
    t.string   "persistence_token",                                      :null => false
    t.string   "perishable_token",                                       :null => false
    t.integer  "login_count",                             :default => 0, :null => false
    t.integer  "failed_login_count",                      :default => 0, :null => false
    t.datetime "last_request_at"
    t.datetime "current_login_at"
    t.datetime "last_login_at"
    t.string   "current_login_ip"
    t.string   "last_login_ip"
  end

end
