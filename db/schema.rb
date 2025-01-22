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

ActiveRecord::Schema[8.1].define(version: 2025_01_22_142003) do
# Could not dump table "customer_reviews" because of following StandardError
#   Unknown type 'uuid' for column 'id'


  create_table "sales_summary_dailies", force: :cascade do |t|
    t.string "country_code", null: false
    t.datetime "created_at", null: false
    t.string "customer_currency", null: false
    t.date "date", null: false
    t.integer "developer_proceeds_in_cents", null: false
    t.string "device", null: false
    t.json "payload"
    t.string "promo_code"
    t.string "provider", null: false
    t.string "sku", null: false
    t.integer "units", null: false
    t.datetime "updated_at", null: false
    t.string "version", null: false
  end

  create_table "subscription_summaries", force: :cascade do |t|
    t.integer "active_free_trial_introductory_offer_subscriptions", null: false
    t.integer "active_standard_price_subscriptions", null: false
    t.string "app_id", null: false
    t.string "app_name", null: false
    t.string "country", null: false
    t.datetime "created_at", null: false
    t.string "customer_currency", null: false
    t.integer "customer_price_in_cents", null: false
    t.date "date", null: false
    t.integer "developer_proceeds_in_cents", null: false
    t.string "device", null: false
    t.string "proceeds_currency", null: false
    t.string "standard_subscription_duration", null: false
    t.string "subscription_name", null: false
    t.integer "subscriptions_total", null: false
    t.datetime "updated_at", null: false
  end
end
