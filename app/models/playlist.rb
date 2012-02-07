class Playlist < ActiveRecord::Base
  has_many :playlist_tracks, :order => "position ASC", :dependent => :destroy, :inverse_of => :playlist
  has_many :tracks, :through => :playlist_tracks
  belongs_to :dj, :class_name => "DJ", :inverse_of => :playlist

  validates_presence_of :dj

  # Change the way the dj attribute is printed in error messages.
  def self.human_attribute_name(attribute, options = {})
    {
      :dj => "DJ"
    }[attribute.to_sym] || super
  end

  def add_track(track)
    return false if ordered_tracks.include? track

    new_track_position = ordered_tracks.size + 1
    playlist_tracks.create :track => track, :position => new_track_position
  end

  def get_track(args)
    raise "You can only pass one argument into Playlist::get_track" unless args.size == 1
    if args[:id]
      tracks.find args[:id].to_i
    end
  end

  def current_track
    ordered_tracks.first
  end

  def remove_current_track
    tracks.delete current_track
    # Then shift the position of all the remaining tracks down by one.
    # Isn't this going to do an UPDATE query for each? Look for more efficient way.
    playlist_tracks(true).each_with_index do |playlist_track, index|
      playlist_track.update_attribute :position, index + 1
    end
    current_track
  end

  def remove_all_tracks
    tracks(true).clear
  end

  # Build an array of the attributes of the tracks that we want to send the client JS.
  # This will be converted to JSON later on.
  def serialize_for_client
    ordered_tracks.map{|track| track.serialize_for_client}
  end

  # Horribly hacky. Find a way to order the has_many :through association.
  def ordered_tracks
    playlist_tracks(true).map(&:track)
  end
end
