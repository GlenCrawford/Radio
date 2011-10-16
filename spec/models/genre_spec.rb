require File.dirname(__FILE__) + '/../spec_helper'

describe Genre do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @genre = genres :genres_0044

    # Connect this genre to its tracks (couldn't fixture).
    Track.find_all_by_album("Organik").each do |track|
      next if track.genres.include?(@genre)
      track.genres << @genre
      track.save!
    end
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @genre.id.should == 84
      @genre.name.should == "experimental"
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @genre.should be_valid
      @genre.save.should be true
    end

    it "should not be valid and have errors" do
      genre = Genre.new
      genre.should_not be_valid
      genre.errors.size.should == 1
      genre.errors.full_messages.sort.should == [
        "Name can't be blank"
      ]
    end

    describe :name do
      it "should have a unique name" do
        genre = Genre.new :name => "house"
        genre.should_not be_valid
        genre.errors.size.should == 1
        genre.errors.full_messages.sort.should == [
          "Name has already been taken"
        ]
      end

      it "should not have an invalid name" do
        genre = Genre.new :name => "classic"
        genre.should_not be_valid
        genre.errors.size.should == 1
        genre.errors.full_messages.sort.should == [
          "You cannot create a Genre with an invalid name"
        ]
      end
    end
  end

  describe :associations do
    describe :tracks do
      it "should have many tracks" do
        @genre.tracks.size.should == 12
        @genre.tracks.first.should be_an_instance_of(Track)
      end

      it "should belong to many tracks" do
        Track.all.select{|track| track.genres.include?(@genre)}.size.should == 12
      end
    end
  end

  describe :callbacks do
    describe :downcase_name do
      it "should downcase the name on before validation" do
        genre = Genre.new :name => "Test"
        genre.valid?
        genre.name.should == "test"
      end
    end
  end

  describe :last_fm_tags_to_ignore do
    it "should have a constant array of string tags to ignore" do
      Genre::LAST_FM_TAGS_TO_IGNORE.should be_an_instance_of(Array)
      Genre::LAST_FM_TAGS_TO_IGNORE.map{|tag| tag.class}.uniq.should == [String]
    end
  end

  describe :is_valid_genre? do
    it "should return true if the string is not an ignored tag" do
      Genre.is_valid_genre?("classic").should be false
    end

    it "should return false if the string is an ignored tag" do
      Genre.is_valid_genre?("rock").should be true
    end
  end

  describe :random do
    it "should not be able to get enough random genres if we ask for too many" do
      lambda {
        Genre.random 9999
      }.should raise_error(RuntimeError, "There aren't enough Genres (need at least 9999).")
    end

    it "should get a default number of random genres" do
      genres = Genre.random
      genres.size.should == 5
      genres.map{|genre| genre.class}.uniq.should == [Genre]
    end

    it "should get a certain number of random genres" do
      genres = Genre.random 7
      genres.size.should == 7
      genres.map{|genre| genre.class}.uniq.should == [Genre]
    end
  end

  describe :get_random_tracks do
    before(:each) do
      @tolerance = @genre.tracks.sort{|a, b| a.length <=> b.length}[-1].length
    end

    it "should get a default amount of time of random tracks" do
      tracks = @genre.get_random_tracks

      tracks.map{|track| track.class}.uniq.should == [Track]

      total_length = tracks.sum{|track| track.length}
      total_length.should > (1.hour - @tolerance)
      total_length.should < (1.hour + @tolerance)
    end

    it "should return as much tracks as it can when we ask for too long an amount of time" do
      tracks = @genre.get_random_tracks(:maximum_total_length => 2.hours)

      tracks.map{|track| track.class}.uniq.should == [Track]
      tracks.size.should == 12

      total_length = tracks.sum{|track| track.length}
      total_length.should < 2.hours
    end

    it "should return just enough when we ask for less an amount of time of tracks" do
      tracks = @genre.get_random_tracks(:maximum_total_length => 30.minutes)

      tracks.map{|track| track.class}.uniq.should == [Track]

      total_length = tracks.sum{|track| track.length}
      total_length.should > (30.minutes - @tolerance)
      total_length.should < (30.minutes + @tolerance)
    end
  end
end
