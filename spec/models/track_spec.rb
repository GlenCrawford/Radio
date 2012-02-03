require File.dirname(__FILE__) + '/../spec_helper'

describe Track do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @track = tracks :tracks_0082

    unless @track.genres.any?
      [:genres_0010, :genres_0028, :genres_0027, :genres_0008, :genres_0029].each do |fixture|
        genre = genres fixture
        @track.genres << genre
        @track.save!
      end
    end
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @track.id.should == 333
      @track.file_path.should == "C:/Users/Glen Crawford/Desktop/RADIO_MUSIC/Hybrid/Disappear Here/The Formula of Fear.mp3"
      @track.title.should == "The Formula of Fear"
      @track.artist.should == "Hybrid"
      @track.album.should == "Disappear Here"
      @track.track_number.should == 6
      @track.image.should == "http://userserve-ak.last.fm/serve/300x300/67253428.jpg"
      @track.release_date.to_s.should == "2010-03-29"
      @track.play_count.should == 7
      @track.length.should == 451.448125
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @track.should be_valid
      @track.save.should be true
    end

    it "should not be valid and have errors" do
      track = Track.new
      track.play_count = nil
      track.should_not be_valid
      track.errors.size.should == 9
      track.errors.full_messages.sort.should == [
        "Album can't be blank",
        "Artist can't be blank",
        "File path can't be blank",
        "Image can't be blank",
        "Length can't be blank",
        "Play count can't be blank",
        "Release date can't be blank",
        "Title can't be blank",
        "Track number can't be blank"
      ]
    end

    describe :track_number do
      it "can only be an integer" do
        @track.track_number = 5.3
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "Track number has to be a positive integer"
        ]
      end

      it "must be greater than zero" do
        @track.track_number = 0
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "Track number has to be a positive integer"
        ]
      end
    end

    describe :play_count do
      it "can only be an integer" do
        @track.play_count = 94.3
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "Play count has to be an integer that is zero or greater"
        ]
      end

      it "must be greater than or equal to zero" do
        @track.play_count = -1
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "Play count has to be an integer that is zero or greater"
        ]
      end
    end

    describe :length do
      it "must be greater than zero" do
        @track.length = 0
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "Length must be a positive number"
        ]
      end
    end

    describe :file_path do
      it "must have a unique file path" do
        @track.file_path = tracks(:tracks_0083).file_path
        @track.should_not be_valid
        @track.errors.size.should == 1
        @track.errors.full_messages.sort.should == [
          "File path has already been added"
        ]
      end
    end
  end

  describe :callbacks do
    it "should set defaults" do
      track = Track.new
      track.play_count.should == 0
    end
  end

  describe :associations do
    describe :vetoes do
      it "should have many vetoes" do
        @track.vetoes.size.should == 3
        @track.vetoes.map{|veto| veto.class}.uniq.should == [Veto]
      end

      it "should destroy the vetoes on destroy" do
        expect {
          @track.destroy
        }.to change(Veto, :count).by(-3)
      end
    end

    describe :genres do
      it "should have many genres" do
        @track.genres.size.should == 5
        @track.genres.map{|genre| genre.class}.uniq.should == [Genre]
        @track.genres.to_a.should == @track.genres.sort{|a, b| a.name <=> b.name}
      end

      it "should belong to many genres" do
        Genre.all.select{|genre| genre.tracks.include?(@track)}.size.should == 5
      end
    end

    describe :playlist_tracks do
      it "should have many playlist_tracks" do
        @track.playlist_tracks.size.should == 1
        @track.playlist_tracks.map{|playlist_track| playlist_track.class}.should == [PlaylistTrack]
      end

      it "should destroy the playlist tracks on destroy" do
        expect {
          @track.destroy
        }.to change(PlaylistTrack, :count).by(-1)
      end
    end

    describe :playlists do
      it "should have many playlists" do
        @track.playlists.size.should == 1
        @track.playlists.map{|playlist| playlist.class}.uniq.should == [Playlist]
        @track.playlists.first.dj.name.should == "Random Genre DJ"
      end
    end
  end

  describe :increment_play_count do
    it "should increment the play count by one - and save" do
      @track.play_count.should == 7
      @track.increment_play_count.should be true
      @track.reload
      @track.play_count.should == 8
    end
  end

  describe :score do
    it "should have a score" do
      @track.score.should == 0.2894770883987415
    end

    it "should have a score of zero if play count is zero" do
      @track.play_count = 0
      @track.score.should == 0
    end

    it "should have a different score with new variables" do
      user = users :josh
      user.veto @track
      @track.increment_play_count

      @track.reload
      @track.score.should == 0.24864188796779113
    end
  end

  describe :serialize_for_client do
    it "should serialize into a hash" do
      result = {}
      [:album, :artist, :id, :image, :release_date, :title, :track_number].each do |attr|
        result[attr.to_s] = @track.send attr
      end
      @track.serialize_for_client.should == result
    end
  end

  describe :to_s do
    it "should pretty print track" do
      @track.to_s.should == "#{@track.artist} - #{@track.title}"
    end
  end

  describe :discover do
    it "should discover new tracks" do
      # Use a canned response instead of going off to LastFM.
      canned_response_path = Rails.root.join "spec", "web_service_responses", "last_fm_album_get_info_dusty_springfield.json"
      canned_response = JSON.parse File.open(canned_response_path).read
      LastFm.should_receive(:poll).with("album.getInfo", {:artist => "Dusty Springfield", :album => "Dusty in Memphis"}).and_return(canned_response)

      @original_stdout = $stdout
      $stdout = StringIO.new

      # For this test, we will be using the spec/assets directory as the music path
      music_path = File.join Rails.root.to_s, "spec", "assets"

      # Clear out all tracks, so we can pretend we're starting fresh.
      # Then create a track in the database that doesn't have a file (so
      # discover will remove it).
      Track.destroy_all
      Track.create! :file_path => File.join(music_path, "Papa Loves Mambo.mp3"), :title => "Papa Loves Mambo", :artist => "Perry Como", :album => "The Very Best of Perry Como", :track_number => 1, :image => "http://ecx.images-amazon.com/images/I/411PsMBHcSL._SL500_AA300_.jpg", :release_date => Date.strptime("2004-10-4"), :length => 160.0
      Track.count.should == 1

      # Discover tracks in the spec/assets directory.
      expect {
        expect {
          Track.discover(music_path).should be true
        }.to change(Genre, :count).by(0)
      }.to change(Track, :count).by(0) # Add one and remove one, so it should break even.

      Track.count.should == 1

      # Now check the new track has all of its attributes filled in.
      new_track = Track.first
      new_track.file_path.should == File.join(music_path, "Son of a Preacher Man.mp3")
      new_track.title.should == "Son of a Preacher Man"
      new_track.artist.should == "Dusty Springfield"
      new_track.album.should == "Dusty in Memphis"
      new_track.track_number.should == 3
      new_track.image.should == "http://userserve-ak.last.fm/serve/300x300/39648137.png"
      new_track.release_date.to_s.should == "1990-08-20" # Not really, this is from the 1990 re-release.
      new_track.play_count.should == 0
      ((new_track.length * 100).round / 100.0).should == 148.14

      # Check that the track was hooken up to its genre(s) correctly.
      new_track.genres.size.should == 1
      new_track.genres.map(&:name).sort.should == ["soul"]

      # Check what was printed to stdout.
      [
        "Discovered Son of a Preacher Man by Dusty Springfield.",
        "Discovered 1 new tracks.",
        "Removed 1 deleted or moved tracks."
      ].each do |expected_string|
        $stdout.string.should include(expected_string)
      end

      $stdout = @original_stdout
    end

    it "should require a valid directory path - from radio app" do
      radio = RadioApp.get
      radio.update_attribute(:music_path, "not_a_real_path").should be true
      lambda {
        Track.discover
      }.should raise_error(RuntimeError, "Cannot find music directory.")
    end

    it "should require a valid directory path - from argument" do
      lambda {
        Track.discover "not_a_real_path_two"
      }.should raise_error(RuntimeError, "Cannot find music directory.")
    end

    it "should skip discovered track if there is an error processing LastFM results" do
      LastFm.should_receive(:poll).once.and_raise(IOError)

      music_path = File.join Rails.root.to_s, "spec", "assets"

      Track.destroy_all

      expect {
        expect {
          Track.discover(music_path).should be true
        }.to change(Genre, :count).by(0)
      }.to change(Track, :count).by(0)
    end
  end
end
