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

  describe :scopes do
    before(:each) do
      @user = users :josh
      Veto.destroy_all
      @vetoes = []
      [
        tracks(:tracks_0155), # Landscape (x2)
        tracks(:tracks_0074), # Steal You Away (x2)
        tracks(:tracks_0074), # Steal You Away (x2)
        tracks(:tracks_0021), # Victory (x1)
        tracks(:tracks_0155)  # Landscape (x2)
      ].each_with_index do |track, index|
        veto = @user.veto track
        veto.update_attribute :created_at, (index + 1).minute.ago
        @vetoes << veto
      end
    end

    describe :distinct_by_track do
      it "should get vetoes distinct by track" do
        vetoes = Veto.distinct_by_track.to_a
        vetoes.size.should == 3
        vetoes.should == [0, 1, 3].map{|i| @vetoes[i]}
      end
    end

    describe :recent_first do
      it "should get recent vetoes first" do
        vetoes = Veto.recent_first.to_a
        vetoes.should == @vetoes
        vetoes.map(&:created_at).should == Veto.all.map(&:created_at).sort{|a, b| b <=> a}
      end
    end
  end
end
