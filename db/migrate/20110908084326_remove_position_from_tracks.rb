class RemovePositionFromTracks < ActiveRecord::Migration
  def self.up
    remove_column :tracks, :position
  end

  def self.down
    add_column :tracks, :position, :integer
  end
end
