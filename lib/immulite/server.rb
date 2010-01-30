require 'strscan'

class Immulite

  class Protocol
    def initialize(string, &block)
    end

    def rest
    end
  end

  module LineBasedProtocol
    def self.call(data, &block)
      scanner = StringScanner.new(data)
      while s = scanner.scan(/.*?\n/)
        yield s.strip
      end
      return scanner.rest
    end
  end

  class Server
    def initialize(protocol, read, write = read)
      @protocol = protocol || LineBasedProtocol
      @read, @rite = read, write
      @buffer = ""
    end

    def on_packet(&block)
      @callback = block
    end

    def run!
      while not @read.eof?
        @buffer = @buffer + @read.readpartial(4096)
        @buffer = @protocol.call(@buffer) do |p|
          @callback.call(p)
        end
      end
    end

  end
end


