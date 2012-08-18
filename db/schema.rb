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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120816224305) do

  create_table "locations", :force => true do |t|
    t.string   "address"
    t.float    "latitude"
    t.float    "longitude"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
  end

  create_table "searches", :force => true do |t|
    t.datetime "created"
    t.string   "user"
    t.integer  "userid"
    t.string   "name"
    t.string   "text"
    t.string   "loc"
    t.string   "timezone"
    t.integer  "statuses"
    t.integer  "followers"
    t.integer  "friends"
    t.string   "source"
    t.float    "lat"
    t.float    "lon"
    t.integer  "mood"
    t.datetime "created_at", :null => false
    t.datetime "updated_at", :null => false
    t.string   "query"
  end

end
