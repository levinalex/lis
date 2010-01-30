require 'helper'

class TestImmuliteServer < Test::Unit::TestCase

  context "a server" do
    setup do
      r1, w1 = IO.pipe # Immulite -> LIS
      r2, w2 = IO.pipe # LIS -> Immulite

      @server = Immulite::Server.new(r1, w2)
      @device = Mock::Immulite.new(r2, w1)
    end

    should "exist" do
      assert_not_nil @server
    end

    should "yield packages written to it" do
      @packets = []
      @server.on_packet { |packet| @packets << packet }

      @device.write("fo").wait.write("o\n").wait.write("bar\n").eof
      @server.run!

      assert_equal ["foo", "bar"], @packets
    end
  end
end