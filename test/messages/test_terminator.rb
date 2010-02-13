require 'helper'

class TestTerminatorMessages < Test::Unit::TestCase
  context "message parsing" do
    setup do
      @message = LIS::Message::Base.from_string("L|1|N")
    end

    should "have correct type" do
      assert_equal LIS::Message::Terminator, @message.class
      assert_equal "L", @message.type_id
    end

    should "have correct sequence number" do
      assert_equal 1, @message.sequence_number
    end
  end

  context "terminator message" do
    should "work" do
      @message = LIS::Message::Terminator.new()
      assert_equal "L|1|N", @message.to_message
    end
  end
end
