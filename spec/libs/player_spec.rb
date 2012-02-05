require 'spec_helper'

describe Player do
  set_fixture_class :djs => "DJ" # Why can't I find a way to set this globally?

  before(:all) do
    @host_address = "142.219.29.175"
    @player = Player.new @host_address
    @client = @player.instance_variable_get :@client
  end

  describe :initialize do
    it "should raise exception when attempting to create another player" do
      lambda {
        Player.new @host_address
      }.should raise_error(Radio::Player::Exceptions::PlayerAlreadyCreatedError, "A Radio Player has already been created.")
      Player.player.should be @player
    end
  end

  describe :reader_methods do
    it "should have a status reader method and be paused on creation" do
      @player.status.should == :paused
    end
  end

  describe :setter_methods do
    describe :host do
      it "should raise exception when given a non-string host address" do
        lambda {
          @player.send :host=, 1337
        }.should raise_error(RuntimeError, "The host address must be a String.")
      end
    end
  end

  describe :instance_variables do
    it "should have miscellaneous instance variables on creation" do
      @player.instance_variable_get(:@status).should == :paused
      @player.instance_variable_get(:@connected).should == false
      @player.instance_variable_get(:@host).should == @host_address

      @player.instance_variable_get(:@volume).should be_an_instance_of(Fixnum)
      @player.instance_variable_get(:@volume).should <= 0
    end

    describe :client do
      it "should have a RAOP client" do
        client = @player.instance_variable_get :@client
        client.should be_an_instance_of(Net::RAOP::Client)
        client.instance_variable_get(:@host).should == @host_address
      end
    end
  end

  describe :class_methods do
    describe :player do
      it "should return the player instance" do
        Player.player.should be @player
      end
    end
  end

  describe :connected? do
    it "should return true if client is connected" do
      @client.stub(:connect).and_return(nil)
      @client.stub(:volume=).and_return(nil)

      @player.send :connect
      @player.send(:connected?).should be true
    end

    it "should return false if client is not connected" do
      @client.stub(:disconnect).and_return(nil)

      @player.send :disconnect
      @player.send(:connected?).should be false
    end
  end

  describe :create_client do
    it "should not allow another client to be created if one already exists" do
      @player.instance_variable_get(:@client).should be_an_instance_of(Net::RAOP::Client)

      lambda {
        @player.send :create_client
      }.should raise_error(Radio::Player::Exceptions::ClientAlreadyCreatedError, "The Radio Player already has a client.")
    end
  end

  describe :disconnect do
    it "should not disconnect if client is already disconnected" do
      #
    end
  end
end
