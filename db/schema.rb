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

ActiveRecord::Schema.define(version: 20161213213857) do

  create_table "annuvin_saves", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "position"
    t.boolean  "human_to_move"
    t.integer  "human_pieces_left"
    t.integer  "computer_pieces_left"
    t.integer  "moving_piece_row"
    t.integer  "moving_piece_column"
    t.integer  "moves_left"
    t.boolean  "force_analysis"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "gomoku_saves", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "position"
    t.boolean  "human_to_move"
    t.integer  "human_last_row"
    t.integer  "human_last_column"
    t.integer  "computer_last_row"
    t.integer  "computer_last_column"
    t.integer  "top"
    t.integer  "bottom"
    t.integer  "left"
    t.integer  "right"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "saved_games", force: :cascade do |t|
    t.integer  "user_id"
    t.text     "position"
    t.boolean  "human_to_move"
    t.integer  "human_pieces_left"
    t.integer  "computer_pieces_left"
    t.integer  "moving_piece_row"
    t.integer  "moving_piece_column"
    t.integer  "moves_left"
    t.boolean  "force_analysis"
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
