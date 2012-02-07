require 'spec_helper'

describe TimeOfDayDJ do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @dj = djs :time_of_day_dj
    @time_format = "%H:%M %d/%m/%Y"
  end

  describe :accessors do
    it "should have a name" do
      @dj.name.should be_an_instance_of(String)
      @dj.name.present?.should be true
    end

    it "should have a description" do
      @dj.description.should be_an_instance_of(String)
      @dj.name.present?.should be true
    end
  end

  describe :need_to_run? do
    before(:each) do
      # Playlist has 30 tracks.
      @dj.playlist.remove_all_tracks
      Track.all[0...30].each do |track|
        @dj.playlist.add_track track
      end
      @dj.playlist.tracks(true).size.should == 30
    end

    it "should need to run if playlist is running low on tracks" do
      # Playlist has 19 tracks.
      @dj.playlist.remove_all_tracks
      Track.all[0...19].each do |track|
        @dj.playlist.add_track track
      end
      @dj.playlist.tracks(true).size.should == 19

      @dj.stub(:changed_time_bracket?).and_return(false)
      @dj.need_to_run?.should be true
    end

    it "should not need to run if playlist has plenty of tracks and time bracket has not changed" do
      @dj.stub(:changed_time_bracket?).and_return(false)
      @dj.need_to_run?.should be false
    end

    it "should need to run if time bracket has changed" do
      @dj.stub(:changed_time_bracket?).and_return(true)
      @dj.need_to_run?.should be true
    end
  end

  describe :time_bracket do
    it "should get bracket for the current hour - hour is in the middle of the current bracket" do
      time = Time.strptime "15:00 19/06/2012", @time_format
      Time.stub(:now).and_return(time)
      @dj.send(:time_bracket).should == 12
    end

    it "should get bracket for the current hour - hour is the start of the current bracket" do
      time = Time.strptime "12:00 19/06/2012", @time_format
      Time.stub(:now).and_return(time)
      @dj.send(:time_bracket).should == 12
    end

    it "should get bracket for the current hour - hour is before first bracket" do
      time = Time.strptime "6:00 19/06/2012", @time_format
      Time.stub(:now).and_return(time)
      @dj.send(:time_bracket).should == 20
    end
  end

  describe :genres do
    it "should get genres for current time bracket" do
      time = Time.strptime "16:00 19/06/2012", @time_format
      Time.stub(:now).and_return(time)
      @dj.send(:genres).map(&:name).sort.should == ["classic rock", "indie", "rock"]
    end
  end

  describe :changed_time_bracket? do
    before(:each) do
      time = Time.strptime "13:00 19/06/2012", @time_format
      Time.stub(:now).and_return(time)
      @dj.send(:time_bracket).should == 12
    end

    it "should have changed time bracket if last time bracket is nil" do
      @dj.data = {}
      @dj.send(:changed_time_bracket?).should be true
    end

    it "should have changed time bracket if last time bracket is different to the current one" do
      @dj.data = {:last_time_bracket => 7}
      @dj.send(:changed_time_bracket?).should be true
    end

    it "should not have changed time bracket if last time bracket is the same as the current one" do
      @dj.data = {:last_time_bracket => 12}
      @dj.send(:changed_time_bracket?).should be false
    end
  end

  describe :run do
    it "should run and add tracks to playlist" do
      existing_track = tracks :tracks_0017
      bracket = 12

      @dj.stub(:time_bracket).and_return(bracket)

      @dj.data[:last_time_bracket] = (bracket - 1)

      @dj.playlist.remove_all_tracks
      @dj.playlist.add_track existing_track
      @dj.playlist.ordered_tracks.size.should == 1
      @dj.playlist.ordered_tracks.should include(existing_track)

      @dj.run.should be true

      @dj.playlist.ordered_tracks.should_not include(existing_track)

      @dj.playlist.tracks.each do |track|
        (track.genres.map(&:name) & TimeOfDayDJ::TIME_BRACKETS[bracket]).any?.should be true
      end

      # Make sure there are no duplicate tracks.
      @dj.playlist.tracks.map(&:id).group_by{|id| id}.values.select{|ids| ids.size > 1}.empty?.should be true

      @dj.data[:last_time_bracket].should == bracket
      @dj.changed?.should be false
    end
  end
end
