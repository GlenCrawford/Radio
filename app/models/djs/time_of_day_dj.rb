class TimeOfDayDJ < DJ
  self.dj_name = "Time of Day DJ"
  self.dj_description = "Plays music to fit the time of the day (or night)."

  TIME_BRACKETS = {
    7 => ["breakbeat", "dub", "reggae", "breaks", "drum and bass"], # Morning - Dub/Reggae.
    12 => ["rock", "classic rock", "indie"], # Afternoon - Rock.
    17 => ["dance", "techno", "trance", "electronic", "eurodance", "trip-hop"], # Evening - Electronic/Trance.
    20 => ["blues", "chillout", "soul", "relaxation", "house", "downtempo", "jazz", "smooth jazz", "ambient", "dream", "experimental", "chill out", "lounge"] # Night (loops around to morning) - Jazz/Ambient/Blues/Chillout.
  }

  def need_to_run?
    (playlist.tracks.size < 20) || changed_time_bracket?
  end

  def run
    playlist.remove_all_tracks if changed_time_bracket?
    tracks = genres.map do |genre|
      genre.get_random_tracks(:maximum_total_length => 1.hour).shuffle
    end
    tracks.flatten!
    tracks.uniq!
    tracks.shuffle!
    tracks.each do |track|
      playlist.add_track track
    end
    data[:last_time_bracket] = time_bracket
    save!
  end

  private

  def time_bracket
    hour = Time.now.hour
    hours = TIME_BRACKETS.keys.sort
    hour = hours.last if hour < hours.first
    hours.select{|time_bracket| time_bracket <= hour}.last
  end

  def genres
    genres = TIME_BRACKETS[time_bracket].map{|genre| "'#{genre.downcase}'"}.join(", ")
    Genre.where "name IN (#{genres})"
  end

  def changed_time_bracket?
    data[:last_time_bracket] != time_bracket
  end
end
