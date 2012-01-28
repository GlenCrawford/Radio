require File.dirname(__FILE__) + '/../spec_helper'

describe Playlist do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @playlist = playlists :random_genre_dj_playlist
    @dj = djs :random_genre_dj
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @playlist.id.should == 1
      @playlist.dj.should == djs(:random_genre_dj)
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @playlist.should be_valid
      @playlist.save.should be true
    end

    it "should not be valid and have errors" do
      playlist = Playlist.new
      playlist.should_not be_valid
      playlist.errors.size.should == 1
      playlist.errors.full_messages.sort.should == [
        "DJ can't be blank"
      ]
    end
  end

  describe :associations do
    describe :playlist_tracks do
      it "should have many playlist_tracks" do
        @playlist.playlist_tracks.size.should == 24
        @playlist.playlist_tracks.first.should be_an_instance_of(PlaylistTrack)
      end

      it "should have playlist_tracks ordered by position" do
        @playlist.playlist_tracks.to_a.map{|playlist_track| playlist_track.position}.should == 1.upto(24).to_a
        @playlist.playlist_tracks.first.track.should == tracks(:tracks_0158)
      end

      it "should destroy all playlist_tracks on destroy" do
        expect {
          @playlist.destroy
        }.to change(PlaylistTrack, :count).by(-24)
      end
    end

    describe :tracks do
      it "should have many tracks" do
        @playlist.tracks.size.should == 24
        @playlist.tracks.first.should be_an_instance_of(Track)
      end

      it "should have tracks ordered by position" do
        @playlist.ordered_tracks.to_a.map{|track| track.playlist_tracks.first.position}.should == 1.upto(24).to_a
      end
    end

    describe :dj do
      it "should have a DJ" do
        @playlist.dj.should_not be_nil
        @playlist.dj.should be_an_instance_of(RandomGenreDJ)
        @playlist.dj.should == @dj
      end
    end
  end

  describe :add_track do
    it "should not add track to playlist if it's already in the playlist" do
      track = tracks :tracks_0038

      @playlist.tracks.include?(track).should be true

      playlist_playlist_tracks_size = @playlist.playlist_tracks.size
      playlist_tracks_size = @playlist.tracks.size

      expect {
        @playlist.add_track(track).should be false
      }.to change(PlaylistTrack, :count).by(0)

      @playlist.reload
      @playlist.playlist_tracks.size.should == playlist_playlist_tracks_size
      @playlist.tracks.size.should == playlist_tracks_size
    end

    it "should add track to playlist and set the position" do
      track = tracks :tracks_0015

      @playlist.tracks.include?(track).should be false

      playlist_playlist_tracks_size = @playlist.playlist_tracks.size
      playlist_tracks_size = @playlist.tracks.size

      playlist_track = nil

      expect {
        playlist_track = @playlist.add_track track
      }.to change(PlaylistTrack, :count).by(1)

      @playlist.reload
      @playlist.playlist_tracks.size.should == (playlist_playlist_tracks_size + 1)
      @playlist.tracks.size.should == (playlist_tracks_size + 1)

      playlist_track.position.should == 25
      playlist_track.track.should == track
      playlist_track.playlist.should == @playlist

      @playlist.playlist_tracks.to_a[-1].should == playlist_track
      @playlist.ordered_tracks.to_a[-1].should == track
    end
  end

  describe :get_track do
    it "should require one argument" do
      lambda {
        @playlist.get_track({})
      }.should raise_error(RuntimeError, "You can only pass one argument into Playlist::get_track")
    end

    it "should return nothing without valid argument" do
      @playlist.get_track(:not_a => "real argument").should be_nil
    end

    it "should find track within playlist by ID" do
      track = @playlist.tracks[15]
      @playlist.get_track(:id => track.id).should == track
    end

    it "should not find a track by ID if not in the playlist" do
      track_id = tracks(:tracks_0056).id

      # Make double sure it does exist.
      Track.find(track_id).should be_an_instance_of(Track)

      lambda {
        @playlist.get_track :id => track_id
      }.should raise_error(ActiveRecord::RecordNotFound)
    end
  end

  describe :current_track do
    it "should get first track in playlist" do
      current_track = tracks :tracks_0158

      @playlist.current_track.should == current_track
      @playlist.playlist_tracks.find_by_position(1).track.should == current_track
      @playlist.current_track.playlist_tracks.first.position.should == 1
    end
  end

  describe :remove_current_track do
    it "should remove the current track from the playlist and return it" do
      current_track = @playlist.current_track
      next_track = @playlist.ordered_tracks[1]

      @playlist.tracks.include?(current_track).should be true

      expect {
        expect {
          @playlist.remove_current_track.should == next_track
        }.to change(Track, :count).by(0)
      }.to change(PlaylistTrack, :count).by(-1)

      @playlist.tracks.include?(current_track).should be false

      @playlist.current_track.should == next_track

      @playlist.playlist_tracks.map{|playlist_track| playlist_track.position}.should == 1.upto(23).to_a
    end
  end

  describe :remove_all_tracks do
    it "should remove all tracks from the playlist" do
      expect {
        expect {
          @playlist.remove_all_tracks
        }.to change(Track, :count).by(0)
      }.to change(PlaylistTrack, :count).by(-24)

      @playlist.tracks.size.should == 0
    end
  end

  describe :serialize_for_client do
    it "should be using the ordered tracks" do
      @playlist.serialize_for_client[0]["id"].should == tracks(:tracks_0158).id
    end

    it "should serialize tracks into a single hash" do
      @playlist.remove_all_tracks
      tracks = tracks(:tracks_0001), tracks(:tracks_0002)
      tracks.each do |track|
        @playlist.add_track track
      end

      @playlist.tracks(true).size.should == tracks.size
      @playlist.playlist_tracks.size.should == tracks.size

      expected_data = tracks.map do |track|
        this_track_data = {}
        [:album, :artist, :id, :image, :release_date, :title, :track_number].each do |attr|
          this_track_data[attr.to_s] = track.send attr
        end
        this_track_data
      end

      @playlist.serialize_for_client.should == expected_data
    end
  end

  describe :ordered_tracks do
    it "should order the tracks by their playlist_tracks position" do
      @playlist.ordered_tracks.should be_an_instance_of(Array)
      @playlist.ordered_tracks.size.should == 24
      @playlist.ordered_tracks.should == @playlist.playlist_tracks.map(&:track)
      @playlist.ordered_tracks.to_a.map{|track| track.playlist_tracks.first.position}.should == 1.upto(24).to_a
      @playlist.ordered_tracks.first.should == tracks(:tracks_0158)
    end
  end
end
