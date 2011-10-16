require File.dirname(__FILE__) + '/../spec_helper'

describe DJ do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @dj = djs :random_genre_dj
    @radio = radio_apps :radio
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @dj.id.should == 1
      @dj.radio.should == @radio
      @dj.should be_an_instance_of(RandomGenreDJ)
    end
  end

  describe :accessors do
    it "should get the DJ's name and description from the class" do
      @dj.name.should == "Random Genre DJ"
      @dj.description.should == "Cycles through genres randomly, playing random tracks from each genre."
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @dj.should be_valid
      @dj.save.should be true
    end

    it "should not be valid and have errors" do
      dj = DJ.new
      dj.should_not be_valid
      dj.errors.size.should == 1
      dj.errors.full_messages.sort.should == [
        "You have to specify a specific DJ; you cannot create an instance of DJ itself."
      ]
    end
  end

  describe :associations do
    describe :radio do
      it "should have a radio app" do
        @dj.radio.should_not be_nil
        @dj.radio.should be_an_instance_of(RadioApp)
        @dj.radio.should == @radio
      end
    end

    describe :playlist do
      it "should have a playlist" do
        @dj.playlist.should_not be_nil
        @dj.playlist.should be_an_instance_of(Playlist)
        @dj.playlist.should == playlists(:random_genre_dj_playlist)
      end

      it "should delete playlist on destroy" do
        expect {
          @dj.destroy
        }.to change(Playlist, :count).by(-1)
      end
    end
  end

  describe :callbacks do
    describe :check_no_existing_of_this_dj do
      it "should not allow two of the same DJ to be created" do
        lambda {
          RandomGenreDJ.create
        }.should raise_error(RuntimeError, "There is already an instance of RandomGenreDJ.")
      end
    end

    describe :set_radio do
      it "should set DJ's radio before validation" do
        dj = RandomGenreDJ.new
        dj.valid?
        dj.radio.should_not be_nil
        dj.radio.should be_an_instance_of(RadioApp)
        dj.radio.should == @radio
      end
    end

    describe :check_playlist do
      it "should create playlist for DJ before validation" do
        dj = RandomGenreDJ.new
        dj.valid?
        dj.playlist.should_not be_nil
        dj.playlist.should be_an_instance_of(Playlist)
        dj.playlist.new_record?.should be true
      end
    end
  end

  describe :get do
    it "should not get an instance of the base class" do
      lambda {
        DJ.get
      }.should raise_error(RuntimeError, "You can only get a specific DJ, not the base one.")
    end

    it "should get a DJ subclass instance" do
      RandomGenreDJ.get.should == @dj
    end
  end

  describe :run do
    it "should throw an exception - meant to be implemented by subclasses" do
      lambda {
        DJ.new.run
      }.should raise_error(NotImplementedError)
    end
  end

  describe :need_to_run? do
    it "should be true when less than 20 tracks in playlist" do
      @dj.playlist.remove_all_tracks
      Track.scoped.limit(19).each do |track|
        @dj.playlist.add_track track
      end
      @dj.reload
      @dj.need_to_run?.should be true
    end

    it "should be false when 20 or more tracks in playlist" do
      @dj.playlist.remove_all_tracks
      Track.scoped.limit(20).each do |track|
        @dj.playlist.add_track track
      end
      @dj.reload
      @dj.need_to_run?.should be false
    end
  end
end
