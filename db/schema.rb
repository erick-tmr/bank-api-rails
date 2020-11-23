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

ActiveRecord::Schema.define(version: 2020_11_21_200507) do

  create_table "accounts", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.integer "balance_cents", default: 0, null: false
    t.string "balance_currency", default: "BRL", null: false
    t.string "name", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
  end

  create_table "transfers", options: "ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_bin", force: :cascade do |t|
    t.bigint "source_id", null: false
    t.bigint "destination_id", null: false
    t.integer "value_cents", default: 0, null: false
    t.string "value_currency", default: "BRL", null: false
    t.integer "initial_balance_cents", default: 0, null: false
    t.string "initial_balance_currency", default: "BRL", null: false
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["destination_id"], name: "index_transfers_on_destination_id"
    t.index ["source_id"], name: "index_transfers_on_source_id"
  end

  add_foreign_key "transfers", "accounts", column: "destination_id"
  add_foreign_key "transfers", "accounts", column: "source_id"
end
