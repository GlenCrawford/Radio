require File.dirname(__FILE__) + '/../spec_helper'

describe RadioApp do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @radio = radio_apps :radio
  end

  describe :attributes do
    it "should have loaded all attributes from fixture" do
      @radio.id.should == 1
      @radio.name.should == "Radio"
      @radio.music_path.should == "C:\\Users\\Glen Crawford\\Desktop\\Music"
    end
  end

  describe :validations do
    it "should validate and be saveable" do
      @radio.should be_valid
      @radio.save.should be true
    end

    it "should not validate and have errors" do
      [:name, :music_path, :dj, :background].each do |attr|
        @radio.send "#{attr.to_s}=", nil
      end

      @radio.should_not be_valid
      @radio.errors.size.should == 4
      @radio.errors.full_messages.sort.should == [
        "Background file name must be set.",
        "Music path must be set to the path of the music directory",
        "Name must be set to the name of the Radio",
        "You need to select a DJ for this Radio!"
      ]
    end
  end

  describe :associations do
    it "should have a DJ" do
      @radio.dj.should_not be_nil
      @radio.dj.should be_an_instance_of(RandomGenreDJ)
    end
  end

  describe :attached_background do
    it "should have a paperclipped background" do
      @radio.background.url.should == "/images/radio_backgrounds/#{@radio.id}/original_background.jpg"
      @radio.background_file_name.should == "background.jpg"
      @radio.background_content_type.should == "image/jpeg"
      @radio.background_file_size.should == 292594
    end
  end

  describe :get do
    it "should get the radio instance" do
      RadioApp.get.should == @radio
    end
  end

  describe :djs do
    it "should get all DJs" do
      djs = @radio.djs
      djs.should be_an_instance_of(Array)
      djs.size.should == 1
      djs.should == [djs(:random_genre_dj)]
    end
  end

  describe :singleton do
    it "should act as a singleton" do
      RadioApp.instance.should == @radio
      lambda {
        RadioApp.new
      }.should raise_error(NoMethodError)
    end
  end
end
