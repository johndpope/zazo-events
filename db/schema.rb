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

ActiveRecord::Schema.define(version: 20150423135215) do

  create_table "events", force: :cascade do |t|
    t.string   "name",         limit: 255
    t.datetime "triggered_at",               precision: 3
    t.string   "triggered_by", limit: 255
    t.string   "initiator",    limit: 255
    t.string   "initiator_id", limit: 255
    t.string   "target",       limit: 255
    t.string   "target_id",    limit: 255
    t.text     "data",         limit: 65535
    t.text     "raw_params",   limit: 65535
    t.datetime "created_at",                 precision: 3, null: false
    t.datetime "updated_at",                 precision: 3, null: false
  end

  add_index "events", ["initiator"], name: "index_events_on_initiator", using: :btree
  add_index "events", ["initiator_id"], name: "index_events_on_initiator_id", using: :btree
  add_index "events", ["name"], name: "index_events_on_name", using: :btree
  add_index "events", ["target"], name: "index_events_on_target", using: :btree
  add_index "events", ["target_id"], name: "index_events_on_target_id", using: :btree
  add_index "events", ["triggered_at"], name: "index_events_on_triggered_at", using: :btree

end
