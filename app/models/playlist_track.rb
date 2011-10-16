class PlaylistTrack < ActiveRecord::Base
  belongs_to :track, :inverse_of => :playlists
  belongs_to :playlist, :inverse_of => :tracks

  validates_presence_of :position, :track, :playlist
  validates_numericality_of :position, :only_integer => true, :greater_than => 0, :message => "has to be a positive integer", :if => :position
end
