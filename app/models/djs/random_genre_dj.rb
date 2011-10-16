class RandomGenreDJ < DJ
  self.dj_name = "Random Genre DJ"
  self.dj_description = "Cycles through genres randomly, playing random tracks from each genre."

  def run
    # Pick some genres at random, and keep them and an hour's worth of random tracks from each genre.
    genres = Genre.random(5).map do |genre|
      {
        :genre => genre,
        :tracks => genre.get_random_tracks(:maximum_total_length => 1.hour)
      }
    end
    # step 3
    # Mix up the tracks within each genre.
    genres.each do |genre|
      genre[:tracks].shuffle!
    end
    # Then mix up the genres themselves.
    genres.shuffle!
    # Build a big array of unique tracks - all the tracks from all the genres together,
    # no longer segregated, but still kept next to tracks of the same genre.
    # This preserves the order set by the above shuffles.
    tracks = []
    genres.each do |genre|
      tracks << genre[:tracks]
    end
    tracks.flatten!
    tracks.uniq!
    # Remove tracks already in the playlist.
    tracks.reject! do |track|
      playlist.tracks.include? track
    end
    # Then, still preserving order, append each track to the playlist.
    tracks.each do |track|
      playlist.add_track track
    end

    true
  end
end
