# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2022_04_30_020030) do

  create_table "notes", force: :cascade do |t|
    t.string "title"
    t.text "body"
    t.integer "user_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_notes_on_user_id"
  end

  create_table "shared_notes", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "note_id", null: false
    t.string "permissions"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.integer "shared_user_id"
    t.index ["note_id"], name: "index_shared_notes_on_note_id"
    t.index ["user_id"], name: "index_shared_notes_on_user_id"
  end

  create_table "tags", force: :cascade do |t|
    t.string "name"
    t.text "tag"
    t.integer "note_id", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["note_id"], name: "index_tags_on_note_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.string "permissions"
    t.string "role"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  add_foreign_key "notes", "users"
  add_foreign_key "shared_notes", "notes"
  add_foreign_key "shared_notes", "users"
  add_foreign_key "tags", "notes"
end
