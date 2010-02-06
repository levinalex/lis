
module LIS::Message

  class Base
    def initialize
    end

    def self.from_string(string)
      message = self.allocate
      message.initialize_from_string(str)
    end

    def self.parse
    end
  end


end