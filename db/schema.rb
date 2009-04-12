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

ActiveRecord::Schema.define(:version => 20090409051106) do

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

  create_table "locations", :force => true do |t|
    t.string   "name"
    t.integer  "type_id"
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
  end

  add_index "locations", ["slug"], :name => "index_locations_on_slug", :unique => true

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

  create_table "types", :force => true do |t|
    t.string   "name"
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
    t.string   "login"
    t.string   "email"
    t.string   "crypted_password",          :limit => 40
    t.string   "salt",                      :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.string   "activation_code",           :limit => 40
    t.datetime "activated_at"
  end

end
