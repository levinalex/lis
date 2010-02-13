require 'strscan'

module LIS::Transfer

  # a chainable IO-Listener that provides to methods:
  #
  # +on_data+ :: a callback that is called whenever a message is received
  # +write+   :: can be called so send messages to the underlying IO
  #
  # when overriding this class, you need to implement two methods:
  #
  # +receive+ :: is called from an underlying IO whenever a message is received
  #              the message can be handled, if messages should be propagated, you
  #              need to call `forward`
  #
  # +write+ :: when data needs to be encoded, formatted before it can be send
  #            send it with `super`
  #
  #
  class Base
    def initialize(read, write = read)
      @reader, @writer = read, write
      @on_data = nil
      @reader.on_data { |*data| receive(*data) } if @reader.respond_to?(:on_data)
    end

    def on_data(&block)
      @on_data = block
    end

    def write(*args)
      @writer.<<(*args) if @writer
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

    def write(data)
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

