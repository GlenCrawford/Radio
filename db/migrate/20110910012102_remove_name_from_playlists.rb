class RemoveNameFromPlaylists < ActiveRecord::Migration
  def self.up
    remove_column :playlists, :name
  end

  def self.down
    add_column :playlists, :name, :string
  end
end
