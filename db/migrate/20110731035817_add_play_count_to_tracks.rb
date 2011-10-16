class AddPlayCountToTracks < ActiveRecord::Migration
  def self.up
    add_column :tracks, :play_count, :integer
    Track.all.each do |track|
      track.update_attribute :play_count, 0
    end
  end

  def self.down
    remove_column :tracks, :play_count
  end
end
