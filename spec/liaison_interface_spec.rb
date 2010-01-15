require 'lib/liaison_labor/interface.rb'

require 'stringio'

include Diasorin::Liaison

context "" do
  setup do
    @to_host = StringIO.new
    @from_host = StringIO.new

    @host = PacketIO.new(LiaisonProtocol, @to_host, @from_host)
    @host.run
  end

  def transmit_string(str)
    @to_host << str
    @to_host.rewind
    30.times { Thread.pass }
    @from_host.rewind
  end

  specify "ENQ should be acknowledged" do
    transmit_string "\x05"
    response = @from_host.read
    response.should == "\x06"
  end

  specify "Valid packet should be acknowledged" do
    s = "\x05\x026L|1|N\x0d\x0309\x0d\x0a"
    transmit_string s
    response = @from_host.read
    response.should == "\x06\x06"
  end

  specify "another valid packet" do
    s = "\005\0023R|1|^^^TSH|0.182|mIU/l||L||F||||20070510161808|Liaison\r\003E2\r\n"
    lambda {
      transmit_string s
      response = @from_host.read
    }.should_not raise_error
  end
end
