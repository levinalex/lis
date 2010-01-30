require 'strscan'

class Immulite
  class Server
    def initialize(read, write = read)
      @read, @rite = read, write
      @buffer = ""
    end

    def on_packet(&block)
      @callback = block
    end

    def run!
      while not @read.eof?
        result = @read.readpartial(4096)
        @buffer = @buffer + result
        data_callback
      end
    end

    def data_callback
      @scanner = StringScanner.new(@buffer)

      while s = @scanner.scan(/.*?\n/)
        @callback.call(s.strip)
      end
      @buffer = @scanner.rest
    end
  end
end


