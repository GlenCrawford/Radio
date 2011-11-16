require File.dirname(__FILE__) + '/../spec_helper'

describe User do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:each) do
    @user = users :josh
  end

  describe :attributes do
    it "should load attributes from fixture" do
      @user.id.should == 1
      @user.first_name.should == "Josh"
      @user.last_name.should == "Topolsky"
      @user.last_seen_at.class.name.should == "Time"
    end
  end

  describe :validations do
    it "should be valid and saveable" do
      @user.should be_valid
      @user.save.should be true
    end

    it "should not be valid and have errors" do
      user = User.new
      user.should_not be_valid
      user.errors.size.should == 3
      user.errors.full_messages.sort.should == [
        "First name can't be blank",
        "Last name can't be blank",
        "Picture file name must be set."
      ]
    end

    it "should not allow a last seen at time from the future" do
      @user.last_seen_at = 5.seconds.from_now
      @user.should_not be_valid
      @user.errors.size.should == 1
      @user.errors.full_messages.sort.should == ["Last seen at can't be in the future"]
    end
  end

  describe :associations do
    it "should have many vetoes" do
      @user.vetoes.size.should == 3
      @user.vetoes.map{|veto| veto.track.id}.should == [333, 408, 458]
    end

    it "should delete vetoes on user destroy" do
      expect {
        @user.destroy
      }.to change(Veto, :count).by(-3)
    end
  end

  describe :scopes do
    describe :by_name do
      it "should get by name ascending" do
        User.by_name.map{|user| user.first_name}.should == ["Josh", "Nilay", "Paul"]
      end
    end

    describe :seen_in_the_last do
      it "should get all users that have visited in the past day" do
        User.seen_in_the_last(1.day).to_a.map(&:name).sort.should == ["Nilay P.", "Paul M."]
      end

      it "should get no users, when none have visited recently" do
        User.seen_in_the_last(5.minutes).to_a.empty?.should be true
      end

      it "should recognize when a user's last seen at time has updated" do
        User.seen_in_the_last(30.minutes).to_a.map(&:name).should == ["Paul M."]
        users(:josh).seen_at 29.minutes.ago
        User.seen_in_the_last(30.minutes).to_a.map(&:name).sort.should == ["Josh T.", "Paul M."]
      end
    end
  end

  describe :attached_picture do
    it "should have a paperclipped picture" do
      @user.picture.url.should == "/images/user_pictures/#{@user.id}/original_the_duet.jpg"
      @user.picture_file_name.should == "the_duet.jpg"
      @user.picture_content_type.should == "image/jpeg"
      @user.picture_file_size.should == 292581
    end
  end

  describe :name do
    it "should format name" do
      @user.name.should == "Josh T."
    end
  end

  describe :veto do
    it "should veto a track" do
      track = tracks :tracks_0051

      track_veto_count = track.vetoes.size
      user_veto_count = @user.vetoes.size

      veto = nil

      expect {
        veto = @user.veto track
      }.to change(Veto, :count).by(1)

      track.reload
      track.vetoes.size.should == (track_veto_count + 1)

      @user.reload
      @user.vetoes.size.should == (user_veto_count + 1)

      veto.user.should == @user
      veto.track.should == track
    end
  end

  describe :seen_at do
    it "should save new last seen at time" do
      time = Time.parse "2007-03-29 11:54:35"

      @user.last_seen_at.should_not == time
      @user.seen_at(time).should be true
      @user.reload
      @user.last_seen_at.should == time
    end
  end

  describe :seen_now do
    it "should set now as the last seen at time" do
      time = Time.parse "2009-05-13 04:34:05"
      Time.should_receive(:now).any_number_of_times.and_return(time)

      @user.last_seen_at.should_not == time
      @user.seen_now.should be true
      @user.reload
      @user.last_seen_at.should == time
    end
  end
end
