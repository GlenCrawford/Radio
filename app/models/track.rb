class Track < ActiveRecord::Base
  has_many :vetoes, :dependent => :destroy
  has_and_belongs_to_many :genres, :order => "name ASC"
  has_many :playlist_tracks, :dependent => :destroy, :inverse_of => :track
  has_many :playlists, :through => :playlist_tracks

  validates_presence_of :file_path, :title, :artist, :album, :track_number, :image, :release_date, :play_count, :length
  validates_numericality_of :track_number, :only_integer => true, :greater_than => 0, :message => "has to be a positive integer", :if => :track_number
  validates_numericality_of :play_count, :only_integer => true, :greater_than_or_equal_to => 0, :message => "has to be an integer that is zero or greater", :if => :play_count
  validates_numericality_of :length, :greater_than => 0, :message => "must be a positive number", :if => :length
  validates_uniqueness_of :file_path, :message => "has already been added"

  after_initialize :set_defaults

  def set_defaults
    self.play_count ||= 0
  end

  def increment_play_count
    new_play_count = play_count + 1
    update_attribute :play_count, new_play_count
  end

  # Derive this track's score from the lower bound of the Wilson score 
  # confidence interval for a Bernoulli parameter.
  # http://www.evanmiller.org/how-not-to-sort-by-average-rating.html
  def score
    finished_plays = play_count - vetoes.size
    power = 0.10
    return 0 if play_count.zero?
    z = Statistics2.pnormaldist(1 - power / 2)
    phat = 1.0 * finished_plays / play_count
    (phat + z * z / (2 * play_count) - z * Math.sqrt((phat * (1 - phat) + z * z / (4 * play_count)) / play_count)) / (1 + z * z / play_count)
  end

  def serialize_for_client
    attributes.keep_if{|key, value| [:id, :title, :artist, :album, :track_number, :image, :release_date].include? key.to_sym}
  end

  def self.discover(music_dir = RadioApp.instance.music_path)
    raise "Cannot find music directory." unless Dir.exists?(music_dir)

    existing_track_count = Track.count

    # Look for mp3 files in all subdirectories of the music directory (and the music directory itself).
    file_pattern = music_dir.gsub("\\", "/") + "/**/*.mp3"
    files_found = Dir.glob file_pattern
    files_found.each do |file_path|
      # Ignore this one if we already have it.
      next if find_by_file_path file_path

      # If it's brand new, start building an instance for it.
      track = new :file_path => file_path

      # Get the track title, artist, album, year and track number info from the MP3's ID3 tags.
      Mp3Info.open(track.file_path) do |mp3|
        track.length = mp3.length
        mp3.tag.each do |key, value|
          key = key.to_sym
          next unless [:title, :artist, :album, :tracknum].include? key
          key = :track_number if key == :tracknum
          track.send "#{key}=", value
        end
      end

      # Skip this file if we don't have, at minimum, the title, artist and album.
      [:title, :artist, :album].each do |tag|
        value = track.send tag
        next if value.nil? || value.empty?
      end

      begin
        # Now phone LastFM for more info about this track's album.
        result = LastFm.poll "album.getInfo", :artist => track.artist, :album => track.album

        # Pick out the image that we want (extra large, preferably).
        track.image = LastFm.pick_image result["album"]["image"]

        # Parse the release date into a Date object and store that, too.
        release_date = result["album"]["releasedate"].strip.sub(", 00:00", "")
        track.release_date = Date.strptime release_date, "%d %b %Y"

        # Get the genres of the track from the tags returned by Last FM.
        result["album"]["toptags"]["tag"].each do |tag|
          tag_name = tag["name"].downcase
          next unless Genre.is_valid_genre? tag_name
          genre = Genre.find_or_create_by_name tag_name
          track.genres << genre
        end
      rescue
        next
      end

      track.save!

      puts "Discovered #{track.title} by #{track.artist}."
    end

    new_track_count = Track.count
    puts "Discovered #{new_track_count - existing_track_count} new tracks."

    # Now destroy tracks that don't exist in the music directory anymore.
    Track.all.each do |track|
      track.destroy unless File.exist? track.file_path
    end

    puts "Removed #{new_track_count - Track.count} deleted or moved tracks."

    true
  end
end
