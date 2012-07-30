
module LIS::Transfer
  class Logging < ::PacketIO::Base
    def initialize(*args)
      @verbose = $VERBOSE
      super
    end

    def receive(type, message=nil)
      output("<", type, message)
      super
    end

    def write(type, message=nil)
      output(">", type, message)
      super
    end


    private

    def output(direction, type, message)
      warn [direction, type.to_s, message].join(" ") if @verbose
    end
  end
end

