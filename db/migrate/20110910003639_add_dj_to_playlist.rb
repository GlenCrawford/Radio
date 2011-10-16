class AddDjToPlaylist < ActiveRecord::Migration
  def self.up
    add_column :playlists, :dj_id, :integer
  end

  def self.down
    remove_column :playlists, :dj_id
  end
end
