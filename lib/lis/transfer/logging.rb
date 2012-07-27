
module LIS::Transfer
  class Logging < ::PacketIO::Base
    def initialize(*args)
      @verbose = $VERBOSE
      super
    end

    def receive(type, message=nil)
      warn ["<", type.to_s, message].join(" ") if @verbose
      super
    end

    def write(type, message=nil)
      warn [">", type.to_s, message].join(" ") if @verbose
      super
    end
  end
end

