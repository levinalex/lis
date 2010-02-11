require 'helper'

class TestApplicationProtocol < Test::Unit::TestCase
  context "application protocol" do
    setup do
      @protocol = LIS::Transfer::ApplicationProtocol.new(nil, nil)
    end

    should "set device name when receiving header message" do
      @protocol.receive(:message,
        "H|\^&||PASSWORD|SenderID|Randolph^New^Jersey^07869||(201)927- 2828|8N1|ReceiverID||P|1|19950522092817")
      assert_equal "SenderID", @protocol.device_name
    end

  end


end