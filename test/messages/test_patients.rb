require 'helper'

class TestPatientMessages < Test::Unit::TestCase
  context "order message" do
    should "have sane defaults" do
      @message = LIS::Message::Patient.new(1, 101, "Riker", "Al")
      assert_equal "P|1|101|||Riker^Al||||||||", @message.to_message
    end
  end
end
