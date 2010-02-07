require 'helper'

class TestPacketizedProtocol < Test::Unit::TestCase

  context "message parsing" do
    setup do
      @message = LIS::Message::Base.from_string("3L|1|N")
    end

    should "have correct frame number" do
      assert_equal 3, @message.frame_number
    end

    should "have correct type" do
      assert_equal LIS::Message::TerminatorRecord, @message.class
      assert_equal "L", @message.type_id
    end

    should "have correct sequence number" do
      assert_equal 1, @message.sequence_number
    end
  end

end