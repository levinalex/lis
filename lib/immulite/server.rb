require 'strscan'

module LIS
end

module LIS::Transfer

  class BaseProtocol
    def initialize(parent = nil)
      @memo = ""
      @parent = parent
    end

    def receive(data, &block)
      if @parent
        @parent.receive(data) { |p| yield p }
      end
    end

    def send(data)
      @parent ? @parent.send(data) : data
    end
  end

  class LineBasedProtocol < BaseProtocol
    def receive(data, &block)
      scanner = StringScanner.new(@memo + data)
      while s = scanner.scan(/.*?\n/)
        yield s.strip
      end
      @memo = scanner.rest
      nil
    end

    def send(packet)
      packet.to_s + "\n"
    end
  end

  class Server
    def initialize(protocol, read, write = read)
      @protocol = protocol || LineBasedProtocol.new
      @read, @write = read, write
    end

    def on_packet(&block)
      @callback = block
    end

    def run!
      while not @read.eof?
        @protocol.receive(@read.readpartial(4096)) do |p|
          @callback.call(p)
        end
      end
    end
  end
end


