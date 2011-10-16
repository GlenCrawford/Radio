require File.dirname(__FILE__) + '/../spec_helper'

describe LastFm do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  describe :api_key do
    it "should have an API key constant" do
      LastFm::API_KEY.should_not be_nil
      LastFm::API_KEY.should be_an_instance_of(String)
      LastFm::API_KEY.size.should > 20
    end
  end

  describe :poll do
    it "should get data from LastFM API - test #1" do
      result = LastFm.poll("track.getInfo", {:artist => "BT", :track => "Never Gonna Come Back Down"})

      # Not going to check every attribute of the response. Just enough to know that it worked.
      result["track"]["album"]["artist"].should == "BT"
      result["track"]["album"]["title"].should == "Movement In Still Life"
      result["track"]["artist"]["name"].should == "BT"
      result["track"]["name"].should == "Never Gonna Come Back Down"
      result["track"]["duration"].should == "345000"
    end

    it "should get data from LastFM API - test #2" do
      result = LastFm.poll("album.getInfo", {:artist => "BT", :album => "This Binary Universe"})

      # Again, not every attribute (it's late).
      result["album"]["artist"].should == "BT"
      result["album"]["name"].should == "This Binary Universe"
      result["album"]["releasedate"].strip.should == "29 Aug 2006, 00:00"
      result["album"]["tracks"]["track"].map{|track| track["name"]}.should == [
        "All That Makes Us Human Continues",
        "Dynamic Symmetry",
        "The Internal Locus",
        "1.618",
        "See You On the Other Side",
        "The Anhtkythera Mechanism",
        "Good Morning Kaia"
      ]
    end
  end

  describe :pick_image do
    before(:each) do
      @images = [
        {
          "#text" => "http://userserve-ak.last.fm/serve/34s/9481813.jpg",
          "size" => "small"
        },
        {
          "#text" => "http://userserve-ak.last.fm/serve/64s/9481813.jpg",
          "size" => "medium"
        },
        {
          "#text" => "http://userserve-ak.last.fm/serve/174s/9481813.jpg",
          "size" => "large"
        },
        {
          "#text" => "http://userserve-ak.last.fm/serve/300x300/9481813.jpg",
          "size" => "extralarge"
        },
        {
          "#text" => "http://userserve-ak.last.fm/serve/_/9481813/This+Binary+Universe+thisbinaryuniverse.jpg",
          "size" => "mega"
        }
      ]
    end

    it "should return the extra large image" do
      image = LastFm.pick_image @images
      image.should == "http://userserve-ak.last.fm/serve/300x300/9481813.jpg"
    end

    it "should return the next largest if larger ones are not present - should get medium" do
      @images = @images.map{|image| ["mega", "extralarge", "large"].include?(image["size"]) ? image.merge("#text" => "") : image}
      image = LastFm.pick_image @images
      image.should == "http://userserve-ak.last.fm/serve/64s/9481813.jpg"
    end

    it "should return an empty string if no image could be picked" do
      @images = @images.map{|image| image.merge("#text" => "")}
      image = LastFm.pick_image @images
      image.should == ""
    end
  end
end
