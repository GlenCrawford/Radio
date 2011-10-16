module Player
  mattr_reader :status
  @@status = :paused

  def self.play(track)
    @@play_status = :playing
    track.increment_play_count
    # # # # # # # # # # # # # # #
    # Implement playing track here.
    return true
    # # # # # # # # # # # # # # #
    DJ.playlist.remove_current_track
    play DJ.playlist.current_track
    true
  end

  def self.pause
    play_status = :paused
    # # # # # # # # # # # # # # #
    # Implement pausing track here.
    # # # # # # # # # # # # # # #
    true
  end
end
