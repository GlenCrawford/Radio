class RemovePlaylistIdFromTracks < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :playlist_id
  end

  def self.down
    add_column :tracks, :playlist_id, :integer
  end
end
