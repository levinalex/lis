require 'helper'

class TestOrderMessages < Test::Unit::TestCase
  context "order message" do
    should "have sane defaults" do
      @message = LIS::Message::Order.new("4","123ABC","TU")
      assert_equal "O|4|123ABC||^^^TU", @message.to_message
    end
  end
end
