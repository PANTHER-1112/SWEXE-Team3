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

ActiveRecord::Schema[8.1].define(version: 2026_11_13_045410) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "categories", force: :cascade do |t|
    t.string "name", null: false
    t.string "disaster_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "facilities", force: :cascade do |t|
    t.bigint "category_id", null: false
    t.string "name", null: false
    t.text "description", null: false
    t.string "address"
    t.float "map_x", null: false
    t.float "map_y", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_id"], name: "index_facilities_on_category_id"
  end

  create_table "stamp_logs", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "facility_id", null: false
    t.datetime "visited_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["facility_id"], name: "index_stamp_logs_on_facility_id"
    t.index ["user_id", "facility_id"], name: "index_stamp_logs_on_user_id_and_facility_id", unique: true
    t.index ["user_id"], name: "index_stamp_logs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_users_on_name", unique: true
  end

  add_foreign_key "facilities", "categories"
  add_foreign_key "stamp_logs", "facilities"
  add_foreign_key "stamp_logs", "users"
end
