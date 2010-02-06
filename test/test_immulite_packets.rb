require 'helper'

class TestLISPacket < Test::Unit::TestCase

  context "" do
    setup do
      @str = "\0021H|\\^&||DPC|Sender|111 Canfield Ave^Randolph^NJ^07869||(201)927-2828|N81|Receiver||P|1|20100206162019\r\0039C\r\n"
      @packet = LIS::Transfer::PacketizedProtocol.message_from_string(@str)
    end
    
    should "work" do
    end
  end
  
end