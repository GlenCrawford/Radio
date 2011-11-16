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

ActiveRecord::Schema.define(:version => 20111115071113) do

  create_table "djs", :force => true do |t|
    t.integer  "radio_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "type"
  end

  create_table "genres", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "genres_tracks", :id => false, :force => true do |t|
    t.integer "genre_id"
    t.integer "track_id"
  end

  create_table "playlist_tracks", :force => true do |t|
    t.integer  "position"
    t.integer  "track_id"
    t.integer  "playlist_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "playlists", :force => true do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "dj_id"
  end

  create_table "radio_apps", :force => true do |t|
    t.string   "name"
    t.string   "music_path"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "background_file_name"
    t.string   "background_content_type"
    t.integer  "background_file_size"
  end

  create_table "tracks", :force => true do |t|
    t.text     "file_path"
    t.string   "title"
    t.string   "artist"
    t.string   "album"
    t.integer  "track_number"
    t.text     "image"
    t.date     "release_date"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "play_count"
    t.float    "length"
  end

  create_table "users", :force => true do |t|
    t.string   "first_name"
    t.string   "last_name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "picture_file_name"
    t.string   "picture_content_type"
    t.integer  "picture_file_size"
    t.datetime "last_seen_at"
  end

  create_table "vetoes", :force => true do |t|
    t.integer  "user_id"
    t.integer  "track_id"
    t.datetime "created_at"
  end

end
