require 'helper'

class TestPacketizedProtocol < Test::Unit::TestCase

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

    match = LIS::Transfer::ASTM::E1394::RX.match(str)
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
      @sent = []
      @data = []
      @protocol = LIS::Transfer::ASTM::E1394.new(nil, @sent)
      @protocol.on_data do |*d|
        @data << d
      end
    end
    should "fire start_of_transmission event when receiving ENQ" do
      @protocol.receive("\005")
      assert_equal [[:begin]], @data
    end

    should "fire end_of_transmission event after EOT is received" do
      @protocol.receive("\005\004")
      assert_equal [[:begin], [:idle]], @data
    end

    should "ignore AKS and NAKs" do
      @protocol.receive("\005\006\025\004")
      assert_equal [[:begin], [:idle]], @data
    end

    should "not fire end_of_transmission event after EOT is received" do
      @protocol.receive("\004")
      assert_equal [], @data
    end

    should "fire trasmission events the correct number of times" do
      @protocol.receive("\005\005")
      @protocol.receive("\004")
      assert_equal [[:begin], [:idle]], @data
      @protocol.receive("\004\005")
      @protocol.receive("\004")
      assert_equal [[:begin], [:idle], [:begin], [:idle]], @data
    end

    should "propagate only packet data" do
      @str = "\0023L|1\r\0033C\r\n"
      @protocol.receive("\005")
      @protocol.receive(@str)
      @protocol.receive("\004")

      assert_equal [[:begin], [:message, "L|1"], [:idle]], @data
    end

    should "add frame number and checksum when sending a message" do
      @protocol.write(:begin)
      @protocol.write(:message, "O|1|130000911||^^^E2")
      @protocol.write(:message, "L|1")
      @protocol.write(:idle)

      assert_equal ["\005",
                    "\0021O|1|130000911||^^^E2\r\00301\r\n",
                    "\0022L|1\r\0033B\r\n",
                    "\004"], @sent
    end
  end

end
