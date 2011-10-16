require File.dirname(__FILE__) + '/../spec_helper'

describe Veto do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @veto = vetoes :veto_001
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @veto.id.should == 1
      @veto.user.should == users(:josh)
      @veto.track.should == tracks(:tracks_0082)
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @veto.should be_valid
      @veto.save.should be true
    end

    it "should not be valid and have errors" do
      veto = Veto.new
      veto.should_not be_valid
      veto.errors.size.should == 2
      veto.errors.full_messages.sort.should == [
        "Track can't be blank",
        "User can't be blank"
      ]
    end
  end

  describe :associations do
    it "should have a user" do
      @veto.user.should_not be_nil
      @veto.user.should be_an_instance_of(User)
      @veto.user.should == users(:josh)
    end

    it "should have a track" do
      @veto.track.should_not be_nil
      @veto.track.should be_an_instance_of(Track)
      @veto.track.should == tracks(:tracks_0082)
    end
  end
end
