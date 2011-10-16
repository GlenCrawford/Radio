class CreateGenresTracks < ActiveRecord::Migration
  def self.up
    create_table :genres_tracks, :id => false do |t|
      t.references :genre
      t.references :track
    end
  end

  def self.down
    drop_table :genres_tracks
  end
end
