module LIS::Message

  class Base
    def self.from_string(string)

    end
  end

  # ["7R|1|^^^TSH|0.902|mIU/L|0.400\\0.004^4.00\\75.0|N|N|R|||20100115105636|20100115120641|B0135"]

end

module LIS::Transfer
  class ApplicationProtocol < Base
    def receive(message, &block)

    end
  end

end