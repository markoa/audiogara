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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110109193730) do

  create_table "artists", :force => true do |t|
    t.string   "name"
    t.string   "mbid"
    t.string   "lastfm_url"
    t.string   "image_small_url"
    t.string   "image_medium_url"
    t.string   "image_large_url"
    t.string   "image_extralarge_url"
    t.string   "image_mega_url"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "similars_processed_at"
    t.string   "code"
  end

  add_index "artists", ["code"], :name => "index_artists_on_code"
  add_index "artists", ["name"], :name => "index_artists_on_name"

  create_table "interests", :force => true do |t|
    t.integer  "user_id"
    t.integer  "artist_id"
    t.float    "score"
    t.string   "artist_name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "interests", ["user_id", "artist_name"], :name => "index_interests_on_user_id_and_artist_name"

  create_table "profile_jobs", :force => true do |t|
    t.integer  "user_id"
    t.datetime "done_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "similar_artists", :force => true do |t|
    t.string   "name"
    t.string   "mbid"
    t.float    "score"
    t.integer  "artist_id"
    t.integer  "parent_artist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "similar_artists", ["name"], :name => "index_similar_artists_on_name"

  create_table "torrents", :force => true do |t|
    t.string   "title"
    t.string   "guid"
    t.string   "link"
    t.datetime "published_at"
    t.string   "artist_name"
    t.string   "album_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "artist_id"
    t.datetime "artist_processed_at"
  end

  create_table "users", :force => true do |t|
    t.string   "lastfm_username"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "users", ["lastfm_username"], :name => "index_users_on_lastfm_username"

end
