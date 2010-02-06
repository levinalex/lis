require 'strscan'

module LIS
end

module LIS::Transfer
  class Base
    def initialize(read, write = read)
      @reader, @writer = read, write
      @on_data = nil
      @reader.on_data { |*data| receive(*data) } if @reader.respond_to?(:on_data)
    end

    def on_data(&block)
      @on_data = block
    end

    def write(message)
      @writer << message if @writer
    end
    def <<(*args)
      write(*args)
    end

    private

    def receive(data)
      forward(data)
    end

    def forward(*data)
      @on_data.call(*data) if @on_data
    end
  end

  class LineBasedProtocol < Base
    def receive(data)
      @memo ||= ""
      scanner = StringScanner.new(@memo + data)
      while s = scanner.scan(/.*?\n/)
        forward(s.strip)
      end
      @memo = scanner.rest
      nil
    end

    def <<(data)
      super(data + "\n")
    end
  end

  class IOListener < Base
    def run!
      while not @reader.eof?
        str = @reader.readpartial(4096)
        forward(str)
      end
    end
  end
end


