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

ActiveRecord::Schema[8.0].define(version: 2025_01_03_132826) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "admins", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "agencies", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "poc_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "agents", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.bigint "agency_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["agency_id"], name: "index_agents_on_agency_id"
    t.index ["user_id"], name: "index_agents_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.string "poc_email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "employees", force: :cascade do |t|
    t.string "name", null: false
    t.string "email", null: false
    t.string "phone"
    t.bigint "company_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["company_id"], name: "index_employees_on_company_id"
    t.index ["user_id"], name: "index_employees_on_user_id"
  end

  create_table "policies", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "company_id"
    t.bigint "agent_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["agent_id"], name: "index_policies_on_agent_id"
    t.index ["company_id"], name: "index_policies_on_company_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: ""
    t.string "role", default: "admin", null: false
    t.string "authenticatable_type"
    t.bigint "authenticatable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["authenticatable_type", "authenticatable_id"], name: "index_users_on_authenticatable"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "admins", "users"
  add_foreign_key "agents", "agencies"
  add_foreign_key "agents", "users"
  add_foreign_key "employees", "companies"
  add_foreign_key "employees", "users"
  add_foreign_key "policies", "agents"
  add_foreign_key "policies", "companies"
end
