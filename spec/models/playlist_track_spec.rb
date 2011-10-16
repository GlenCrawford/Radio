require File.dirname(__FILE__) + '/../spec_helper'

describe PlaylistTrack do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @playlist_track = playlist_tracks :playlist_tracks_0013
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @playlist_track.id.should == 318
      @playlist_track.position.should == 13
      @playlist_track.track.should == tracks(:tracks_0027)
      @playlist_track.playlist.should == playlists(:random_genre_dj_playlist)
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @playlist_track.should be_valid
      @playlist_track.save.should be true
    end

    it "should not be valid and have errors" do
      playlist_track = PlaylistTrack.new
      playlist_track.should_not be_valid
      playlist_track.errors.size.should == 3
      playlist_track.errors.full_messages.sort.should == [
        "Playlist can't be blank",
        "Position can't be blank",
        "Track can't be blank"
      ]
    end

    describe :position do
      it "should be an integer" do
        @playlist_track.position = 44.6
        @playlist_track.should_not be_valid
        @playlist_track.errors.size.should == 1
        @playlist_track.errors.full_messages.sort.should == [
          "Position has to be a positive integer"
        ]
      end

      it "should be greater than zero" do
        @playlist_track.position = -5
        @playlist_track.should_not be_valid
        @playlist_track.errors.size.should == 1
        @playlist_track.errors.full_messages.sort.should == [
          "Position has to be a positive integer"
        ]
      end
    end
  end

  describe :associations do
    describe :track do
      it "should have a track" do
        @playlist_track.track.should_not be_nil
        @playlist_track.track.should be_an_instance_of(Track)
        @playlist_track.track.should == tracks(:tracks_0027)
      end
    end

    describe :playlist do
      it "should have a playlist" do
        @playlist_track.playlist.should_not be_nil
        @playlist_track.playlist.should be_an_instance_of(Playlist)
        @playlist_track.playlist.should == playlists(:random_genre_dj_playlist)
      end
    end
  end
end
