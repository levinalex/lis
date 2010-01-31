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
    end
  end

  packet_should_match "<ENQ>", "<ENQ>"
  packet_should_match "<EOT>", "<EOT>"
  packet_should_match "<STX>packet_data<CR><ETX>checksum<CR><LF>", 
                      "<STX>packet_data<CR><ETX>checksum<CR><LF><STX>packet_data<CR><ETX>checksum<CR><LF>rest"

end