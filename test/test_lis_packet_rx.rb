require 'helper'

class TestLISPacket < Test::Unit::TestCase

  def self.gsub_nonprintable(str)
    str.gsub(/<[A-Z]+?>/) do |match|
      { "<ETX>" => "\003",
        "<STX>" => "\002",
        "<CR>" => "\015",
        "<LF>" => "\012",
        "<ENQ>" => "\004",
        "<EOT>" => "\005" }[match] or raise ArgumentError, "match #{match.inspect} not found"
    end
  end

  def assert_packet_matches(expected, str)
    str = self.class.gsub_nonprintable(str)
    expected = self.class.gsub_nonprintable(expected)

    match = LIS::Transfer::PacketizedProtocol::RX.match(str)
    assert_not_nil match, expected
    assert_equal expected, match[0]
  end

  def self.packet_should_match(expected, str)
    should "match \"#{str}\" as \"#{expected}\"" do
      assert_packet_matches(expected, str)
      assert_packet_matches(expected, "garbage" + str)
      assert_packet_matches(expected, str + "garbage")
    end
  end

  packet_should_match "<ENQ>", "<ENQ>"
  packet_should_match "<EOT>", "<EOT>"
  packet_should_match "<STX>packet_data<CR><ETX>checksum<CR><LF>",
                      "<STX>packet_data<CR><ETX>checksum<CR><LF><STX>packet_data<CR><ETX>checksum<CR><LF>rest"

  context "packetized protocol" do
    setup do
      @protocol = LIS::Transfer::PacketizedProtocol.new
      @protocol.end_of_transmission do
        @eot_counter = (@eot_counter || 0) + 1
      end
      @protocol.start_of_transmission do
        @enq_counter = (@enq_counter || 0) + 1
      end
    end
    should "fire start_of_transmission event when receiving ENQ" do
      @protocol.receive("\004")
      assert_equal 1, @enq_counter
    end

    should "fire end_of_transmission event after EOT is received" do
      @protocol.receive("\004\005")
      assert_equal 1, @eot_counter
    end

    should "not fire end_of_transmission event after EOT is received" do
      @protocol.receive("\005")
      assert_equal nil, @eot_counter
    end

    should "fire trasmission events the correct number of times" do
      @protocol.receive("\004\004")
      @protocol.receive("\005")
      assert_equal 1, @enq_counter
      assert_equal 1, @eot_counter
      @protocol.receive("\005\004")
      @protocol.receive("\005")
      assert_equal 2, @enq_counter
      assert_equal 2, @eot_counter
    end
  end

end