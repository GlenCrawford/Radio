class CreatePlaylistTracks < ActiveRecord::Migration
  def self.up
    create_table :playlist_tracks do |t|
      t.integer :position
      t.references :track
      t.references :playlist

      t.timestamps
    end
  end

  def self.down
    drop_table :playlist_tracks
  end
end
