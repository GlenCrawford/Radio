require File.dirname(__FILE__) + '/../spec_helper'

describe RandomGenreDJ do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @dj = djs :random_genre_dj
  end

  describe :accessors do
    describe :name do
      it "should be available on the class" do
        RandomGenreDJ.dj_name.should be_an_instance_of(String)
        RandomGenreDJ.dj_name.present?.should be true
      end

      it "should be available on the instance" do
        @dj.name.should be_an_instance_of(String)
        @dj.name.present?.should be true
      end
    end

    describe :description do
      it "should be available on the class" do
        RandomGenreDJ.dj_description.should be_an_instance_of(String)
        RandomGenreDJ.dj_description.present?.should be true
      end

      it "should be available on the instance" do
        @dj.description.should be_an_instance_of(String)
        @dj.description.present?.should be true
      end
    end
  end

  describe :run do
    it "should be implemented" do
      @dj.respond_to?(:run).should be true
      lambda {
        @dj.run
      }.should_not raise_error(NotImplementedError)
    end

    it "should choose random genres and tracks" do
      # Pick five arbitrary genres.
      genres = Genre.where(:name => ["smooth jazz", "experimental", "rock", "breakbeat", "trance"])
      expected_playlist = genres.map{|genre| genre.tracks[0...5]}.flatten

      # Always return these five genres, their first five tracks, and prevent any shuffling.
      Genre.stub!(:random).and_return(genres)
      genres.each do |genre|
        genre_tracks = genre.tracks[0...5]
        genre_tracks.stub!(:shuffle!)
        genre.stub!(:get_random_tracks).and_return(genre_tracks)
      end

      # Build the array of hashes of genres and tracks to be returned when the
      # random genres are mapped, and stub it to prevent them from being shuffled.
      genres_and_tracks = genres.map{|genre| {:genre => genre, :tracks => genre.get_random_tracks}}
      genres_and_tracks.stub(:shuffle!)
      genres.stub!(:map).and_return(genres_and_tracks)

      # Clear the DJ's current playlist of any tracks.
      @dj.playlist.remove_all_tracks
      @dj.playlist.tracks.empty?.should be true
      @dj.need_to_run?.should be true

      lambda {
        @dj.run.should be true
      }.should change(PlaylistTrack, :count).from(0).to(25)

      @dj.playlist.tracks(true).size.should == 25
      @dj.playlist.ordered_tracks.should == expected_playlist
      @dj.playlist.ordered_tracks.map{|track| track.playlist_tracks.first.position}.should == 1.upto(25).to_a
    end
  end
end
