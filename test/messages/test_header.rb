require 'helper'

class TestHeaderMessages < Test::Unit::TestCase
  context "header message" do
    setup do
      Time.stubs(:now).returns(Time.mktime(2010,2,15,17,28,32))
    end

    should "have sane defaults" do
      @message = LIS::Message::Header.new()
      assert_equal "H|\\^&|||SenderID||||8N1|ReceiverID||P|1|20100215172832", @message.to_message
    end

    should "have overridable sender and receiver IDs" do
      @message = LIS::Message::Header.new("SEND", "RECV", "PASSWORD")
      assert_equal "H|\\^&||PASSWORD|SEND||||8N1|RECV||P|1|20100215172832", @message.to_message
    end
  end
end
