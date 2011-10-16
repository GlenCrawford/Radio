class AddLengthToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :length, :float
  end

  def self.down
    remove_column :tracks, :length
  end
end
