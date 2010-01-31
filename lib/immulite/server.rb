require 'strscan'

module LIS
end

module LIS::Transfer

  class BaseProtocol
    def initialize(parent = nil)
      @parent = parent
    end

    def receive(memo, data)
      if @parent
        @memo = @parent.receive(memo, data) { |p| yield p }
      end
    end

    def send(data)
      @parent ? @parent.send(data) : data
    end
  end

  class LineBasedProtocol < BaseProtocol
    def receive(memo, data, &block)
      scanner = StringScanner.new(memo + data)
      while s = scanner.scan(/.*?\n/)
        yield s.strip
      end
      return scanner.rest
    end

    def send(packet)
      packet.to_s + "\n"
    end
  end

  class Server
    def initialize(protocol, read, write = read)
      @protocol = protocol || LineBasedProtocol.new
      @read, @rite = read, write
      @buffer = ""
    end

    def on_packet(&block)
      @callback = block
    end

    def run!
      while not @read.eof?
        @buffer = @protocol.receive(@buffer, @read.readpartial(4096)) do |p|
          @callback.call(p)
        end
      end
    end
  end
end


