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

ActiveRecord::Schema[7.0].define(version: 2023_08_22_165500) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "channel_configs", force: :cascade do |t|
    t.string "chat_platform"
    t.string "channel_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "external_account_id"
    t.string "escalation_policy_id"
    t.string "team_id"
    t.datetime "disabled_at"
    t.index ["external_account_id", "channel_id"], name: "index_channel_configs_on_external_account_id_and_channel_id", unique: true
    t.index ["external_account_id"], name: "index_channel_configs_on_external_account_id"
  end

  create_table "channel_subscribers", force: :cascade do |t|
    t.bigint "customer_user_id", null: false
    t.bigint "channel_config_id", null: false
    t.datetime "disabled_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["channel_config_id"], name: "index_channel_subscribers_on_channel_config_id"
    t.index ["customer_user_id"], name: "index_channel_subscribers_on_customer_user_id"
  end

  create_table "customer_users", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "slack_user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_id"], name: "index_customer_users_on_customer_id"
    t.index ["slack_user_id"], name: "index_customer_users_on_slack_user_id"
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slack_team_id"
    t.string "slack_access_token"
    t.uuid "external_id", default: -> { "gen_random_uuid()" }
    t.bigint "installer_customer_user_id"
    t.index ["external_id"], name: "index_customers_on_external_id"
    t.index ["slack_team_id"], name: "index_customers_on_slack_team_id"
  end

  create_table "events", force: :cascade do |t|
    t.string "platform"
    t.jsonb "event"
    t.string "external_id"
    t.bigint "message_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_events_on_external_id", unique: true
    t.index ["message_id"], name: "index_events_on_message_id"
  end

  create_table "external_accounts", force: :cascade do |t|
    t.string "platform"
    t.string "external_id"
    t.bigint "customer_id", null: false
    t.string "token"
    t.string "refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "disabled_at"
    t.index ["customer_id"], name: "index_external_accounts_on_customer_id"
  end

  create_table "messages", force: :cascade do |t|
    t.text "content"
    t.string "channel_id"
    t.bigint "customer_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.jsonb "event_payload", default: {}
    t.string "external_id"
    t.string "slack_ts"
    t.bigint "customer_user_id"
    t.string "external_url"
    t.index ["channel_id"], name: "index_messages_on_channel_id"
    t.index ["customer_id"], name: "index_messages_on_customer_id"
    t.index ["customer_user_id"], name: "index_messages_on_customer_user_id"
    t.index ["external_id"], name: "index_messages_on_external_id"
  end

  create_table "support_case_reviews", force: :cascade do |t|
    t.bigint "support_case_id", null: false
    t.bigint "reviewer_id", null: false
    t.string "status"
    t.boolean "resolved"
    t.integer "satisfication"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["reviewer_id"], name: "index_support_case_reviews_on_reviewer_id"
    t.index ["support_case_id"], name: "index_support_case_reviews_on_support_case_id"
  end

  create_table "support_cases", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "channel_id"
    t.string "slack_ts"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "instigator_message_id"
    t.index ["channel_id"], name: "index_support_cases_on_channel_id"
    t.index ["created_at"], name: "index_support_cases_on_created_at"
    t.index ["customer_id"], name: "index_support_cases_on_customer_id"
    t.index ["instigator_message_id"], name: "index_support_cases_on_instigator_message_id"
    t.index ["slack_ts"], name: "index_support_cases_on_slack_ts"
  end

  create_table "user_contact_associations", force: :cascade do |t|
    t.bigint "user_contact_id", null: false
    t.bigint "customer_user_id", null: false
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["customer_user_id"], name: "index_user_contact_associations_on_customer_user_id"
    t.index ["user_contact_id", "customer_user_id"], name: "idx_user_contact_assoc_unique", unique: true
    t.index ["user_contact_id"], name: "index_user_contact_associations_on_user_contact_id"
  end

  create_table "user_contacts", force: :cascade do |t|
    t.string "method"
    t.string "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["number"], name: "index_user_contacts_on_number"
  end

  add_foreign_key "customer_users", "customers"
  add_foreign_key "external_accounts", "customers"
  add_foreign_key "messages", "customers"
  add_foreign_key "support_case_reviews", "customer_users", column: "reviewer_id"
  add_foreign_key "support_case_reviews", "support_cases"
  add_foreign_key "support_cases", "customers"
  add_foreign_key "support_cases", "messages", column: "instigator_message_id"
  add_foreign_key "user_contact_associations", "customer_users"
  add_foreign_key "user_contact_associations", "user_contacts"
end
