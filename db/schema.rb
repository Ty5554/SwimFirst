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

ActiveRecord::Schema[7.2].define(version: 2025_02_18_145537) do
  create_table "bodies", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.float "height", null: false
    t.float "weight", null: false
    t.float "body_fat", null: false
    t.date "recorded_on"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_bodies_on_user_id"
  end

  create_table "conditions", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "fatigue_level", null: false
    t.float "body_temperature", null: false
    t.float "sleep_hours", null: false
    t.integer "mental_state", null: false
    t.date "recorded_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_conditions_on_user_id"
  end

  create_table "diaries", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.date "recorded_on"
    t.text "feedback"
    t.index ["user_id"], name: "index_diaries_on_user_id"
  end

  create_table "heart_rates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "training_set_id", null: false
    t.bigint "user_id", null: false
    t.integer "training_heart_rate", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_set_id"], name: "index_heart_rates_on_training_set_id"
    t.index ["user_id"], name: "index_heart_rates_on_user_id"
  end

  create_table "roles", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.integer "role"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_roles_on_user_id"
  end

  create_table "self_records", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "style", null: false
    t.integer "distance", null: false
    t.integer "record", null: false
    t.date "recorded_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_self_records_on_user_id"
  end

  create_table "sns_credentials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "provider"
    t.string "uid"
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "google_access_token"
    t.text "google_refresh_token"
    t.index ["user_id"], name: "index_sns_credentials_on_user_id"
  end

  create_table "team_invitations", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "team_id", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["team_id"], name: "index_team_invitations_on_team_id"
    t.index ["user_id"], name: "index_team_invitations_on_user_id"
  end

  create_table "teams", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "team_name", null: false
    t.string "invitation_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invitation_token"], name: "index_teams_on_invitation_token", unique: true
  end

  create_table "training_menus", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.date "training_date", null: false
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_training_menus_on_user_id"
  end

  create_table "training_sets", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "training_menu_id", null: false
    t.integer "set_number", null: false
    t.integer "intensity", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["training_menu_id", "set_number"], name: "index_training_sets_on_training_menu_id_and_set_number", unique: true
    t.index ["training_menu_id"], name: "index_training_sets_on_training_menu_id"
    t.index ["user_id"], name: "index_training_sets_on_user_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.boolean "modal_shown"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "bodies", "users"
  add_foreign_key "conditions", "users"
  add_foreign_key "diaries", "users"
  add_foreign_key "heart_rates", "training_sets"
  add_foreign_key "heart_rates", "users"
  add_foreign_key "roles", "users"
  add_foreign_key "self_records", "users"
  add_foreign_key "sns_credentials", "users"
  add_foreign_key "team_invitations", "teams"
  add_foreign_key "team_invitations", "users"
  add_foreign_key "training_menus", "users"
  add_foreign_key "training_sets", "training_menus"
  add_foreign_key "training_sets", "users"
end
