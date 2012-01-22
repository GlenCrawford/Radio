require 'spec_helper'

describe ApplicationHelper do
  describe :time_ago_in_words do
    it "returns the time ago in words - real, recent time" do
      time = 29.seconds.ago
      helper.time_ago_in_words(time).should == "Less than a minute ago"
    end

    it "returns the time ago in words - real, far time" do
      time = (5.days + 3.hours + 43.minutes + 6.seconds).ago
      helper.time_ago_in_words(time).should == "5 days ago"
    end

    it "returns the time ago in words - nil time" do
      helper.time_ago_in_words(nil).should == "Never"
    end
  end
end
