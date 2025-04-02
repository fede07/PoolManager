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

ActiveRecord::Schema[8.0].define(version: 2025_04_02_194401) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "matches", force: :cascade do |t|
    t.bigint "player1_id", null: false
    t.bigint "player2_id", null: false
    t.datetime "start_time", null: false
    t.datetime "end_time"
    t.bigint "winner_id"
    t.integer "table_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["player1_id"], name: "index_matches_on_player1_id"
    t.index ["player2_id"], name: "index_matches_on_player2_id"
    t.index ["winner_id"], name: "index_matches_on_winner_id"
  end

  create_table "players", force: :cascade do |t|
    t.string "auth0_id", null: false
    t.string "name", null: false
    t.integer "ranking", default: 0
    t.string "preferred_cue"
    t.string "profile_picture_url", default: "", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auth0_id"], name: "index_players_on_auth0_id", unique: true
  end

  add_foreign_key "matches", "players", column: "player1_id"
  add_foreign_key "matches", "players", column: "player2_id"
  add_foreign_key "matches", "players", column: "winner_id"
end
