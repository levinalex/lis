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

    def write(packet)
      @on_send.call(packet)
    end

    def on_data(&block)
      @on_send = block
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

    def write(data)
      super(data + "\n")
    end
  end

  class Server
    def initialize(protocol, read, write = read)
      @protocol = protocol || LineBasedProtocol.new
      @read, @write = read, write
      @protocol.on_data  { |str|
        @write.write(str)
      }
    end

    def on_packet(&block)
      @callback = block
    end

    def run!
      while not @read.eof?
        str = @read.readpartial(4096)
        @protocol.receive(str) do |p|
          @callback.call(p)
        end
      end
    end
  end
end


